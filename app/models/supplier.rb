class Supplier < ApplicationRecord
  include AASM

  HOTEL_SUPPLIERS = %w[ZentrumHub Travclan].freeze

  validates :name, inclusion: { in: HOTEL_SUPPLIERS }

  # ─── State Machine ───────────────────────────────────────────
  aasm column: :state do
    state :inactive, initial: true
    state :active

    event :activate do
      transitions from: :inactive, to: :active
    end
  end

  def self.zentrumhub
    @zentrumhub ||= active.find_by(name: "ZentrumHub")
  end

  def rate_sync_job
    "Suppliers::#{name.gsub(' ', '').downcase.camelize}::HotelRateSyncJob".constantize
  end
end
