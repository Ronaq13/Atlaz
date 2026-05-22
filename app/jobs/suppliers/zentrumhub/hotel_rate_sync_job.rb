class Suppliers::Zentrumhub::HotelRateSyncJob < ApplicationJob
  queue_as :low

  # Four lookahead windows: cheapest 1-night rate at each horizon.
  RATE_WINDOWS = [
    { months: 1 },
    { months: 3 },
    { months: 6 },
    { months: 9 }
  ].freeze

  def perform(hotel_ids:)
    hotels = Hotel.where(id: hotel_ids)
    supplier_hotel_ids = hotels.pluck(:supplier_hotel_id).compact

    return if supplier_hotel_ids.empty?

    hotel_id_map = hotels.pluck(:supplier_hotel_id, :id).to_h

    RATE_WINDOWS.each do |window|
      check_in  = window[:months].months.from_now.to_date
      check_out = check_in + 1.day

      normalized = Suppliers::Zentrumhub::Hotels::HotelAvailability.call(
        hotel_ids: supplier_hotel_ids,
        check_in:  check_in,
        check_out: check_out
      )[:normalized_availability]

      upsert_rates!(normalized, till_date: check_in, hotel_id_map: hotel_id_map)
    end
  end

  private

  def upsert_rates!(normalized, till_date:, hotel_id_map:)
    return if normalized.empty?

    now = Time.current

    currency_id_map = Currency
      .where(code: normalized.map { |a| a[:starting_price_currency_code] }.uniq.compact)
      .pluck(:code, :id)
      .to_h

    rows = normalized.filter_map do |attrs|
      hotel_id    = hotel_id_map[attrs[:supplier_hotel_id]]
      currency_id = currency_id_map[attrs[:starting_price_currency_code]]
      next if hotel_id.nil? || currency_id.nil?

      {
        hotel_id:        hotel_id,
        currency_id:     currency_id,
        starting_amount: attrs[:starting_price],
        till_date:       till_date,
        synced_at:       now,
        created_at:      now,
        updated_at:      now
      }
    end

    return if rows.empty?

    HotelRate.upsert_all(
      rows,
      unique_by: :index_hotel_rates_on_hotel_id_and_till_date_unique,
      update_only: %w[currency_id starting_amount synced_at updated_at]
    )
  end
end
