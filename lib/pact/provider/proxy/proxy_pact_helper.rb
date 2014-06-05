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
