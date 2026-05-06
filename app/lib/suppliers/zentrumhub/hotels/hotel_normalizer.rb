class Suppliers::Zentrumhub::Hotels::HotelNormalizer < ::Normalizers::BaseHotelNormalizer
  def address
    address = @raw_hotel_payload.dig(:contact, :address)
    main = [
      address[:line1],
      address[:line2],
      address.dig(:city, :name),
      address.dig(:state, :name),
      address.dig(:country, :name)
    ].compact_blank.join(", ")
    code = address[:postal_code].presence
    code ? "#{main} - #{code}" : main
  end

  def description
    [ @raw_hotel_payload[:name], @raw_hotel_payload[:chainName] ].join(" by ")
  end

  def lat
    @raw_hotel_payload.dig(:geoCode, :lat)
  end

  def long
    @raw_hotel_payload.dig(:geoCode, :long)
  end

  def name
    @raw_hotel_payload[:name]
  end

  def supplier_id
    @supplier.id
  end

  def supplier_product_id
    @raw_hotel_payload[:id]
  end

  def class_rating
    r = @raw_hotel_payload[:starRating]
    return if r.blank?

    Integer(r)
  rescue ArgumentError, TypeError
    nil
  end

  def hero_image_url
    @raw_hotel_payload[:heroImage]
  end
end
