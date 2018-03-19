require "sidekiq/throttled"
Sidekiq::Throttled.setup!

if ENV.key? 'REDIS_URL'
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL') }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL') }
  end
end
