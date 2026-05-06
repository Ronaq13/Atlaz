class StartStaticSyncJob < ApplicationJob
  queue_as :default

  def perform
    StaticSyncConfig.all.each do |config|
      job = config.job_name.constantize.new
      job.perform_later(
        {
        static_sync_config_id: config.id,
        page: config.from_page
        }.compact_blank
      )
    end
  end
end
