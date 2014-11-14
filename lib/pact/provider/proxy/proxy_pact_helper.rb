# This pact_helper is always set as the pact_helper for the `pact verify` command.
# If there was a pact_helper specified by the user, its location is stored in
# ENV['PACT_PROJECT_PACT_HELPER'] and it is loaded by this pact_helper.

require 'pact/provider/rspec'
require 'rack/reverse_proxy'

Pact.service_provider "Running Provider Application" do
  app do
    Rack::ReverseProxy.new do
      reverse_proxy '/', ENV.fetch('PACT_PROVIDER_BASE_URL')
    end
  end
end

require ENV['PACT_PROJECT_PACT_HELPER'] if ENV.fetch('PACT_PROJECT_PACT_HELPER','') != ''
