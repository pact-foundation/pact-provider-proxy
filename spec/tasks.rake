require 'pact/proxy/tasks'

Pact::ProxyVerificationTask.new :test_proxy do | task |
 task.pact_uri './spec/support/pact.json', :pact_helper => './spec/support/pact_helper'
 task.provider_base_url 'http://localhost:9292'
end

namespace :pact do
  namespace :test do
    task :spawn_test_monolith do
      require 'pact/consumer/app_manager'
      Pact::Consumer::AppManager.instance.register lambda { | env | [200, {}, ["Monolith!"]] }, 9292
      Pact::Consumer::AppManager.instance.spawn_all
    end
  end
end

task 'pact:verify:test_proxy' => 'pact:test:spawn_test_monolith'

task :spec => ['pact:verify:test_proxy']
task :default => [:spec]