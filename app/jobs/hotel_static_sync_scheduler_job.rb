class HotelStaticSyncSchedulerJob < ApplicationJob
  queue_as :default

  def perform
    HotelStaticSyncConfig.all.each do |config|
      job_class = config.job_name.constantize
      if Rails.env.development?
        job_class.perform_now(static_sync_config_id: config.id)
      else
        job_class.perform_later(static_sync_config_id: config.id)
      end
    end
  end
end
