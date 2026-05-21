class Suppliers::Zentrumhub::Hotels::HotelAvailabilityNormalizer
  attr_reader :raw_hotel, :response_currency

  def self.normalize(raw_hotel:, response_currency: nil)
    new(raw_hotel: raw_hotel, response_currency: response_currency).normalize
  end

  def initialize(raw_hotel:, response_currency: nil)
    @raw_hotel = raw_hotel.with_indifferent_access
    @response_currency = response_currency
  end

  # Returns nil if no usable rate is present (hotel will be skipped).
  def normalize
    return nil if total_rate.nil?

    {
      supplier_hotel_id:          raw_hotel[:id].to_s,
      starting_price:             total_rate,
      starting_price_currency_code: currency
    }
  end

  private

  def rate
    @rate ||= raw_hotel[:rate]&.with_indifferent_access
  end

  def total_rate
    value = rate&.dig(:totalRate)
    return nil if value.nil?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end

  def currency
    rate&.dig(:currency).presence || response_currency
  end
end
