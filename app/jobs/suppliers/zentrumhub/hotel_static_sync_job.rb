class Suppliers::Zentrumhub::HotelStaticSyncJob < ApplicationJob
  queue_as :low

  BATCH_SIZE = 1000
  UPSERT_UNIQUE_INDEX = "index_hotels_on_supplier_id_and_supplier_hotel_id_unique"

  UPSERT_UPDATE_FIELDS = %w[
    address description lat long name class_rating amenities customer_rating hero_image_url destination_id type updated_at
  ].freeze

  # Columns written by upsert_all (string keys), excluding timestamps handled separately.
  UPSERT_ATTRIBUTE_NAMES = %w[
    address description lat long name supplier_id supplier_hotel_id slug type destination_id state
    class_rating customer_rating amenities hero_image_url
  ].freeze

  def perform(args)
    @config = HotelStaticSyncConfig.find(args[:static_sync_config_id])

    geo_result     = Suppliers::Zentrumhub::Location::GeoLocation.call(location_id: @config.supplier_destination_id)
    hotel_payloads = Suppliers::Zentrumhub::Hotels::HotelContent.call(**geo_result)[:normalized_hotels_attributes]

    hotel_payloads = hotel_payloads

    hotel_payloads.each_slice(BATCH_SIZE) do |batch|
      upsert_hotel_batch!(batch)
    end
  end

  private

  def destination
    @destination ||= @config.destination
  end

  def upsert_hotel_batch!(batch)
    now = Time.current
    supplier_id = Supplier.zentrumhub.id
    supplier_hotel_ids = batch.map { |p| (p[:supplier_hotel_id] || p["supplier_hotel_id"]).to_s }
    existing_by_key = Hotel.where(supplier_id: supplier_id, supplier_hotel_id: supplier_hotel_ids)
      .includes(:destination)
      .index_by { |p| p.supplier_hotel_id.to_s }

    rows = batch.filter_map do |normalized_attrs|
      hotel = build_hotel_for_validation(normalized_attrs, existing_by_key: existing_by_key, destination: destination)
      next unless hotel.valid?(:hotel_static_sync)

      upsert_row_from_hotel(hotel, now: now)
    end

    return if rows.empty?

    Hotel.upsert_all(
      rows,
      unique_by: UPSERT_UNIQUE_INDEX,
      update_only: UPSERT_UPDATE_FIELDS
    )
  end

  def build_hotel_for_validation(normalized_attrs, existing_by_key:, destination:)
    attrs = normalized_attrs.deep_stringify_keys
    key = attrs["supplier_hotel_id"].to_s
    record = existing_by_key[key] || ZentrumhubHotel.new

    assignable = attrs.slice(*assignable_from_normalized_keys(attrs))
    record.assign_attributes(assignable)
    record.destination = destination
    record.type = ZentrumhubHotel.name
    record.state = "inactive" if record.state.blank?
    record.slug = nil unless record.persisted?

    record
  end

  def assignable_from_normalized_keys(attrs)
    attrs.keys & ZentrumhubHotel.column_names
  end

  def upsert_row_from_hotel(hotel, now:)
    row = hotel.attributes.slice(*UPSERT_ATTRIBUTE_NAMES)
    row["created_at"] = now
    row["updated_at"] = now
    row
  end
end
