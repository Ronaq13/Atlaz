class HotelStaticSyncSchedulerJob < ApplicationJob
  queue_as :default

  def perform
    HotelStaticSyncConfig.all.each do |config|
      job = config.job_name.constantize.new
      job.perform_later(static_sync_config_id: config.id)
    end
  end
end
