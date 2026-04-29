class Country < Destination
  has_many :states
  has_many :cities, through: :states
end
