class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  scope :ordered, -> { order(:position) }
end
