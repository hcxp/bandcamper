# Configure your routes here
# See: http://hanamirb.org/guides/routing/overview/
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }

namespace :v1 do
  get '/bands/:guid', to: 'v1/bands#by_guid'
end
