class Suppliers::Zentrumhub::Hotels::HotelContent < Suppliers::Zentrumhub::Client
  URL = "https://nexus.prod.zentrumhub.com/api/content/HotelContent/getHotelContent".freeze

  def call(polygonalRegionCoordinates:)
    post(URL, body: {
      channelId: Rails.application.credentials.dig(:zentrum_hub, :channel_id),
      hotelIds: nil, # Note: This API also works with hotelIDs. Not a usecase as of now but good thing to keep in mind for future.
      polygonalRegion: {
        coordinates: polygonalRegionCoordinates
      }
    })

    raw_hotels_payload = parsed_response_body[:hotels]

    normalized_hotels_attributes = raw_hotels_payload.map do |raw_hotel|
      Suppliers::Zentrumhub::Hotels::HotelNormalizer.normalize(
        raw_hotel_payload: raw_hotel,
        supplier: Supplier.zentrumhub
      )
    end

    {
      normalized_hotels_attributes: normalized_hotels_attributes
    }
  end
end
