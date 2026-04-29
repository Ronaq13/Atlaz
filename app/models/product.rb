# app/models/product.rb
class Product < ApplicationRecord
  include AASM

  # ─── Constants ───────────────────────────────────────────────
  SOURCES       = %w[manual sheet viator klook booking_com].freeze
  BOOKING_TYPES = %w[direct redirect both].freeze
  DETAIL_TYPES  = %w[HotelDetail ActivityDetail TransferDetail].freeze

  # ─── Delegations ─────────────────────────────────────────────
  delegated_type :detail, types: DETAIL_TYPES

  # ─── Associations ────────────────────────────────────────────
  belongs_to :currency
  belongs_to :city, optional: true
  belongs_to :state, optional: true
  delegated_type :detail, types: %w[HotelDetail ActivityDetail TransferDetail]

  has_many :images,           as: :imageable, dependent: :destroy

  # ─── Validations ─────────────────────────────────────────────
  validates :name,         presence: true
  validates :slug,         presence: true, uniqueness: true
  validates :detail_type,  inclusion: { in: DETAIL_TYPES }
  validate  :city_or_state_present

  # ─── State Machine ───────────────────────────────────────────
  aasm column: :state do
    state :draft, initial: true
    state :active
    state :inactive
    state :archived

    event :publish do
      transitions from: %i[draft inactive], to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end

    event :archive do
      transitions from: %i[draft inactive], to: :archived
    end
  end

  # ─── Scopes ──────────────────────────────────────────────────
  scope :active,              -> { where(state: "active") }
  scope :draft,               -> { where(state: "draft") }
  scope :in_city,             ->(city_id) { where(city_id: city_id) }
  scope :of_type,             ->(type) { where(detail_type: "#{type.to_s.camelize}Detail") }
  scope :sync_availability,   -> { where(sync_availability: true) }
  scope :sync_pricing,        -> { where(sync_pricing: true) }

  # ─── Callbacks ───────────────────────────────────────────────
  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    self.slug = name.parameterize
  end

  def city_or_state_present
    errors.add(:base, "must belong to a city or a state") if city_id.blank? && state_id.blank?
  end
end
