class Suppliers::Zentrumhub::Hotels::HotelAvailability < Suppliers::Zentrumhub::Client
  URL = "https://nexus.prod.zentrumhub.com/api/hotel/availability".freeze

  # Default occupancy: 1 room, 2 adults.
  DEFAULT_OCCUPANCIES = [ { numOfAdults: 2, numOfChildren: 0, childAges: [] } ].freeze
  DEFAULT_CURRENCY    = "INR".freeze

  def call(check_in: Date.tomorrow, check_out: Date.tomorrow + 1, hotel_ids: nil, polygonal_region_coordinates: nil, occupancies: DEFAULT_OCCUPANCIES)
    raise ArgumentError, "pass either hotel_ids or polygonal_region_coordinates" if hotel_ids.nil? && polygonal_region_coordinates.nil?

    body = {
      channelId:   Rails.application.credentials.dig(:zentrum_hub, :channel_id),
      currency:    DEFAULT_CURRENCY,
      checkIn:     check_in.iso8601,
      checkOut:    check_out.iso8601,
      occupancies: occupancies
    }

    if hotel_ids
      body[:hotelIds] = hotel_ids.map(&:to_s)
    else
      body[:polygonalRegion] = { coordinates: polygonal_region_coordinates }
    end

    post(URL, body: body)

    raw_hotels = parsed_response_body[:hotels] || []
    response_currency = parsed_response_body[:currency]

    normalized = raw_hotels.filter_map do |raw_hotel|
      Suppliers::Zentrumhub::Hotels::HotelAvailabilityNormalizer.normalize(
        raw_hotel: raw_hotel,
        response_currency: response_currency
      )
    end

    { normalized_availability: normalized }
  end
end
