class Suppliers::Zentrumhub::Hotels::HotelContent < Suppliers::Zentrumhub::Client
  URL = "https://nexus.prod.zentrumhub.com/api/content/HotelContent/getHotelContent".freeze

  def call(polygonal_lat_lng_boundaries: nil, multi_polygonal_lat_lng_boundaries: nil)
    post(URL, body: build_body(polygonal_lat_lng_boundaries, multi_polygonal_lat_lng_boundaries))

    raw_hotels_payload = parsed_response_body[:hotels]

    normalized_hotels_attributes = raw_hotels_payload.map do |raw_hotel|
      Suppliers::Zentrumhub::Hotels::HotelNormalizer.normalize(
        raw_hotel_payload: raw_hotel,
        supplier: Supplier.zentrumhub
      )
    end

    { normalized_hotels_attributes: normalized_hotels_attributes }
  end

  private

  def build_body(polygonal, multi_polygonal)
    body = {
      channelId: Rails.application.credentials.dig(:zentrum_hub, :channel_id),
      hotelIds:  nil
    }

    if multi_polygonal.present?
      body[:multiPolygonalRegion] = {
        polygons: multi_polygonal.map { |boundary| { coordinates: boundary.flatten } }
      }
    elsif polygonal.present?
      body[:polygonalRegion] = { coordinates: polygonal.flatten }
    end

    body
  end
end
