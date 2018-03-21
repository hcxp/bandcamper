source 'https://rubygems.org'

ruby '2.5.0'

gem 'rake'
gem 'hanami',       '~> 1.1'
gem 'hanami-model', '~> 1.1'
gem 'jsonapi-hanami', github: 'jsonapi-rb/jsonapi-hanami'
gem 'sidekiq'
gem 'sidekiq-throttled'
gem 'spidr'
gem 'sinatra', require: false

gem 'sqlite3'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun'
end

group :test, :development do
  gem 'dotenv', '~> 2.0'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'webmock'
  gem 'hanami-fabrication'
  gem 'simplecov', require: false
  gem 'database_cleaner'
end

group :production do
  # gem 'puma'
end
