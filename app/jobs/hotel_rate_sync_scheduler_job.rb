class HotelRateSyncSchedulerJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 500

  def perform
    Supplier.active.each do |supplier|
      Hotel
        .where(sync_rate: true, supplier_id: supplier.id)
        .pluck(:id)
        .each_slice(BATCH_SIZE) do |hotel_ids|
          supplier.rate_sync_job.perform_now(hotel_ids: hotel_ids)
        end
    end
  end
end
