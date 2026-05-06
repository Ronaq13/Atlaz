class Normalizers::BaseHotelNormalizer
  def self.normalize(raw_hotel_payload:, supplier:)
    new(raw_hotel_payload: raw_hotel_payload, supplier: supplier).normalize
  end

  def normalize
    {
      name: name,
      description: description,
      address: address,
      lat: lat,
      long: long,
      supplier_id: supplier_id,
      supplier_product_id: supplier_product_id,
      class_rating: class_rating,
      customer_rating: customer_rating,
      hero_image_url: hero_image_url,
      amenities: amenities,
      images_attributes: images_attributes
    }
  end

  def supplier_id
    raise NotImplementedError
  end

  def supplier_product_id
    raise NotImplementedError
  end

  def name
    raise NotImplementedError
  end

  def address
    raise NotImplementedError
  end

  def lat
    raise NotImplementedError
  end

  def long
    raise NotImplementedError
  end

  def hero_image_url
    raise NotImplementedError
  end

  def description
    name
  end

  def class_rating
    nil
  end

  def customer_rating
    nil
  end

  def images_attributes
    []
  end

  def amenities
    {}
  end

  private

  def initialize(raw_hotel_payload:, supplier:)
    @raw_hotel_payload = raw_hotel_payload
    @supplier = supplier
  end
end
