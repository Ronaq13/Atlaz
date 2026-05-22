# app/models/hotel.rb
class Hotel < ApplicationRecord
  include AASM

  # ─── Constants ───────────────────────────────────────────────
  SOURCES       = %w[manual sheet viator klook booking_com].freeze
  BOOKING_TYPES = %w[direct redirect both].freeze

  # ─── Associations ────────────────────────────────────────────
  belongs_to :destination
  belongs_to :supplier, optional: true

  has_many :rates, class_name: "HotelRate", dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :images, allow_destroy: true

  # ─── Validations ─────────────────────────────────────────────
  validates :name, presence: true
  validates :slug, uniqueness: true, allow_blank: true

  # ─── State Machine ───────────────────────────────────────────
  aasm column: :state do
    state :inactive, initial: true
    state :active
    state :archived

    event :publish do
      transitions from: %i[inactive], to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end

    event :archive do
      transitions from: %i[inactive], to: :archived
    end
  end

  # ─── Scopes ──────────────────────────────────────────────────
  scope :active,            -> { where(state: "active") }
  scope :with_rates,        -> { where.associated(:rates) }

  # ─── Callbacks ───────────────────────────────────────────────
  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if validation_context == :hotel_static_sync

    return if slug.present?

    self.slug = name.parameterize
  end
end
