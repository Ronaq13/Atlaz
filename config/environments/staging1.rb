require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled, but unlike production we allow local request info for debugging.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Use debug level on staging so issues are easier to trace.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Report deprecations to help catch issues before they hit production.
  config.active_support.report_deprecations = true

  # Use Redis-backed cache store (shares the host Redis instance).
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL") }

  # Use Sidekiq for background jobs.
  config.active_job.queue_adapter = :sidekiq

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "staging1.atlaz.thrillo.dev" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "staging.example.com",
  #   /.*\.staging\.example\.com/
  # ]
  #
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
