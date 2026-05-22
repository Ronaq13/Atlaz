class Search::HotelSearchQuery
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE     = 100

  # Picks the rate field closest to the requested check_in date.
  RATE_WINDOWS = [
    { months: 1, field: "rate_1m" },
    { months: 3, field: "rate_3m" },
    { months: 6, field: "rate_6m" },
    { months: 9, field: "rate_9m" }
  ].freeze

  def initialize(params)
    @q              = params[:q].presence || "*"
    @destination_id = params[:destination_id]
    @check_in       = parse_date(params[:check_in])
    @min_price      = params[:min_price]
    @max_price      = params[:max_price]
    @class_rating   = params[:class_rating]
    @sort_by        = params[:sort_by]       # "price_asc" | "price_desc" | "rating_desc"
    @page           = [params[:page].to_i, 1].max
    @per_page       = [[params[:per_page].to_i, DEFAULT_PER_PAGE].max, MAX_PER_PAGE].min
  end

  def call
    TYPESENSE_CLIENT.collections["hotels"].documents.search(search_params)
  end

  private

  def search_params
    params = {
      q:           @q,
      query_by:    "name,description,address",
      sort_by:     sort_expression,
      page:        @page,
      per_page:    @per_page
    }

    filters = build_filters
    params[:filter_by] = filters if filters.present?

    params
  end

  def rate_field
    return "rate_1m" unless @check_in

    months_ahead = ((@check_in - Date.today) / 30).round
    window = RATE_WINDOWS.min_by { |w| (w[:months] - months_ahead).abs }
    window[:field]
  end

  def sort_expression
    case @sort_by
    when "price_asc"   then "#{rate_field}:asc"
    when "price_desc"  then "#{rate_field}:desc"
    when "rating_desc" then "class_rating:desc"
    else "#{rate_field}:asc"
    end
  end

  def build_filters
    filters = []
    filters << "destination_id:=#{@destination_id}" if @destination_id.present?
    filters << "class_rating:=#{@class_rating}"     if @class_rating.present?

    if @min_price.present? || @max_price.present?
      min = @min_price.presence || "0"
      max = @max_price.presence
      filters << (max ? "#{rate_field}:[#{min}..#{max}]" : "#{rate_field}:>=#{min}")
    end

    filters.join(" && ")
  end

  def parse_date(value)
    Date.parse(value) rescue nil if value.present?
  end
end
