class State < Destination
  belongs_to :country
  has_many :cities
end
