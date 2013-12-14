require 'rake/tasklib'
require 'pact/tasks/task_helper'

module Pact
  class ProxyVerificationTask < ::Rake::TaskLib

    include Pact::TaskHelper

    attr_reader :pact_spec_configs

    def initialize(name)
      @pact_spec_configs = []
      @provider_base_url = nil
      @name = name
      yield self
      rake_task
    end


    def pact_url(uri, options = {})
      @pact_spec_configs << {uri: uri, pact_helper: options.fetch(:pact_helper, pact_helper_url)}
    end

    # For compatiblity with the normal VerificationTask, allow task.uri
    alias_method :uri, :pact_url

    def provider_base_url url
      @provider_base_url = url
    end

    def pact_helper_url
      File.expand_path('../../pact_helper', __FILE__)
    end

    private

    attr_reader :name

    def rake_task
      namespace :pact do
        desc "Verify provider against the consumer pacts for #{name}"
        task "verify:#{name}", :description, :provider_state do |t, args|

          require 'pact/provider/pact_spec_runner'
          require 'pact/proxy/configure_service_provider'

          Pact::Proxy::ConfigureServiceProvider.call @provider_base_url
          options = {criteria: spec_criteria(args)}

          handle_verification_failure do
            Provider::PactSpecRunner.new(@pact_spec_configs, options).run
          end
        end
      end
    end
  end
end
