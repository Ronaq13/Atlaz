class HotelRate < ApplicationRecord
  belongs_to :hotel
  belongs_to :currency

  validates :starting_amount, presence: true, numericality: { greater_than: 0 }
  validates :till_date, presence: true
  validates :synced_at, presence: true
  validates :hotel_id, uniqueness: { scope: :till_date }
end
