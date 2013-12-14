require 'pact/provider/rspec'
require 'rack/reverse_proxy'

module Pact
  module Proxy

    class ConfigureServiceProvider

      def self.call provider_base_url

        Pact.service_provider "Running Provider Application" do
          app do
            Rack::ReverseProxy.new do
              reverse_proxy '/', provider_base_url
            end
          end
        end

      end
    end
  end
end