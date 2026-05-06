class Suppliers::Zentrumhub::Location::GeoLocation < Suppliers::Zentrumhub::Client
  def call(location_id:, get_sublocations: false)
    get(
      "https://autosuggest.travel.zentrumhub.com/api/locations/LocationContent/location/#{location_id}?getSublocations=#{get_sublocations}"
    )

    result = {}

    # Expecting cities are always polygons.
    result[:polygonal_lat_lng_boundaries] = parsed_response_body[:boundaries] if parsed_response_body[:shape].eql?("Polygon")

    result.present? ? result : handle_exceptional_response
  end

  private

  def handle_exceptional_response
    raise "Error: No polygon shape in response for location_id: #{@location_id}. Response: #{parsed_response_body.to_json}"
  end
end
