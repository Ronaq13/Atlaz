class Search::HotelSearchDocument
  RATE_WINDOW_MONTHS = { rate_1m: 1, rate_3m: 3, rate_6m: 6, rate_9m: 9 }.freeze

  def self.from_hotel(hotel)
    new(hotel).to_h
  end

  def initialize(hotel)
    @hotel = hotel
    @rates = hotel.rates.index_by { |r| r.till_date.month }
  end

  def to_h
    {
      id:              @hotel.id.to_s,
      name:            @hotel.name.to_s,
      description:     @hotel.description.to_s,
      address:         @hotel.address.to_s,
      slug:            @hotel.slug.to_s,
      hero_image_url:  @hotel.hero_image_url.to_s,
      class_rating:    @hotel.class_rating.to_i,
      customer_rating: @hotel.customer_rating.to_i,
      amenities:       amenity_names,
      destination_id:  @hotel.destination_id,
      state:           @hotel.state.to_s,
      lat:             @hotel.lat.to_f,
      long:            @hotel.long.to_f,
      **rate_fields,
      currency:        currency_code
    }
  end

  private

  def rate_for_window(months)
    target_month = months.months.from_now.month
    @rates[target_month]
  end

  def rate_fields
    RATE_WINDOW_MONTHS.transform_values do |months|
      rate_for_window(months)&.starting_amount.to_f
    end
  end

  def currency_code
    @rates.values.first&.currency&.code.to_s
  end

  def amenity_names
    Array(@hotel.amenities).map(&:to_s)
  end
end
