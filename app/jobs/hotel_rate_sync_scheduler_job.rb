class HotelRateSyncSchedulerJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 500

  def perform
    Supplier.active.each do |supplier|
      Hotel
        .where(sync_rate: true, supplier_id: supplier.id)
        .pluck(:id)
        .each_slice(BATCH_SIZE) do |hotel_ids|
          job_class = supplier.rate_sync_job
          if Rails.env.development?
            job_class.perform_now(hotel_ids: hotel_ids)
          else
            job_class.perform_later(hotel_ids: hotel_ids)
          end
        end
    end
  end
end
