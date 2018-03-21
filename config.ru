require './config/environment'
require 'sidekiq/web'

map '/sidekiq' do
  run Sidekiq::Web
end

run Hanami.app
