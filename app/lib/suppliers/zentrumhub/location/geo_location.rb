class Suppliers::Zentrumhub::Location::GeoLocation < Suppliers::Zentrumhub::Client
  def call(location_id:, get_sublocations: false)
    get(
      "https://autosuggest.travel.zentrumhub.com/api/locations/LocationContent/location/#{location_id}?getSublocations=#{get_sublocations}"
    )

    case parsed_response_body[:shape]
    when "Polygon"
      { polygonal_lat_lng_boundaries: parsed_response_body[:boundaries] }
    when "MultiPolygon"
      { multi_polygonal_lat_lng_boundaries: parsed_response_body[:boundaries] }
    else
      handle_exceptional_response
    end
  end

  private

  def handle_exceptional_response
    raise "Error: Unsupported or missing shape in response. Response: #{parsed_response_body.to_json}"
  end
end
