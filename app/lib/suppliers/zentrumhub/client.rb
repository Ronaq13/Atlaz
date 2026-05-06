require "zlib"
require "stringio"

class Suppliers::Zentrumhub::Client
  def self.call(*args, **kwargs)
    new.call(*args, **kwargs)
  end

  def get(url, query: {})
    @response = HTTParty.get(url, headers: default_headers, query: query, verbose: true)

    @response.success? ? parsed_response_body : handle_error
  end

  def post(url, body: {})
    @request_payload = body
    @response = HTTParty.post(url, headers: default_headers, body: body.to_json, verbose: true)

    @response.success? ? parsed_response_body : handle_error
  end

  private

  def parsed_response_body
    @parsed_response_body ||= response_body.is_a?(String) ? JSON.parse(response_body, symbolize_names: true) : {}
  end

  def response_body
    @response_body ||= if @response.headers["content-encoding"].eql? "gzip"
      io = StringIO.new(@response.body)
      gz = Zlib::GzipReader.new(io)
      gz.read
    else
      @response.body
    end
  end

  def handle_error
    # TODO: handle error properly, send to sentry as well
    Rails.logger.info(
      "[ZentrumHub-API-Error] request_payload=#{@request_payload.to_json} response_payload=#{response_body}"
    )
    raise "Error: #{@response.code} #{@response.message}"
  end

  def default_headers
    {
      "Content-Type" => "application/json; charset=utf-8",
      "Accept-Encoding" => "gzip, deflate",
      "accountId" => Rails.application.credentials.dig(:zentrum_hub, :account_id),
      "apiKey" => Rails.application.credentials.dig(:zentrum_hub, :api_key),
      "correlationId" => SecureRandom.uuid # TODO: use request-id here
    }
  end
end
