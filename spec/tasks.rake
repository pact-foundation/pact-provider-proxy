require 'pact/provider/proxy/tasks'

Pact::ProxyVerificationTask.new :middleware do | task |
 task.pact_url './spec/support/pact.json', :pact_helper => './spec/support/middleware_pact_helper'
 task.provider_base_url 'http://localhost:9494'
end

Pact::ProxyVerificationTask.new :monolith do | task |
 task.pact_url './spec/support/pact.json', :pact_helper => './spec/support/custom_pact_helper'
 task.provider_base_url 'http://localhost:9292'
end

Pact::ProxyVerificationTask.new :monolith_ssl do | task |
 task.pact_url './spec/support/pact.json', :pact_helper => './spec/support/custom_pact_helper'
 task.provider_base_url 'https://localhost:9393'
end

desc 'Shutdown SSL monolith server after pact:verify'
task 'pact:verify:monolith_ssl' do | foo, bar |
  Process.kill('INT', @@ssl_server_pid) if @@ssl_server_pid
end

Pact::ProxyVerificationTask.new :monolith_no_pact_helper do | task |
 task.pact_url './spec/support/pact-with-no-provider-states.json'
 task.provider_base_url 'http://localhost:9292'
end

namespace :pact do
  namespace :test do
    task :spawn_test_monolith do
      require 'pact/mock_service/app_manager'
      app = lambda { | env | [200, {"Content-Type" => "text/plain"}, ["Monolith!"]] }
      Pact::MockService::AppManager.instance.register app, 9292
      Pact::MockService::AppManager.instance.spawn_all
    end

    task :spawn_test_monolith_which_needs_dynamic_header do
      require 'pact/mock_service/app_manager'
      app = lambda { | env |
        require 'date'
        expiry = DateTime.strptime(env['HTTP_X_EXPIRY'], "%Y-%m-%d")
        if expiry > DateTime.now
          [200, {"Content-Type" => "text/plain"}, ["Monolith!"]]
        else
          [401, {"Content-Type" => "text/plain"}, ["Expired!"]]
        end
      }
      Pact::MockService::AppManager.instance.register app, 9494
      Pact::MockService::AppManager.instance.spawn_all
    end

    task :spawn_test_monolith_ssl do
      @@ssl_server_pid = fork do
        trap 'INT' do @server.shutdown end
        require 'rack'
        require 'rack/handler/webrick'
        require 'webrick/https'

        app = lambda { | env | [200, {"Content-Type" => "text/plain"}, ["Monolith!"]] }
        webrick_opts = {:Port => 9393, :SSLEnable => true, :SSLCertName => [%w[CN localhost]]}
        Rack::Handler::WEBrick.run(app, webrick_opts) do |server|
          @server = server
        end
      end
      sleep 2
    end
  end
end

task 'delete_pact_helper' do
  FileUtils.rm_rf './spec/support/pact_helper.rb'
end

task 'create_pact_helper' do
  FileUtils.cp './spec/fixtures/template_pact_helper.rb', './spec/support/pact_helper.rb'
end

task 'create_pact_helper_that_should_not_be_loaded' do
  FileUtils.cp './spec/fixtures/do_not_load_pact_helper.rb', './spec/support/pact_helper.rb'
end

task 'create_custom_pact_helper' do
  FileUtils.cp './spec/fixtures/template_pact_helper.rb', './spec/support/custom_pact_helper.rb'
end

task 'pact:verify:monolith' => ['pact:test:spawn_test_monolith', 'delete_pact_helper', 'create_custom_pact_helper']
task 'pact:verify:monolith_ssl' => ['pact:test:spawn_test_monolith_ssl', 'delete_pact_helper', 'create_custom_pact_helper']
task 'pact:verify:monolith_no_pact_helper' => ['pact:test:spawn_test_monolith', 'delete_pact_helper', 'create_pact_helper_that_should_not_be_loaded']
task 'pact:verify:middleware' => ['pact:test:spawn_test_monolith_which_needs_dynamic_header']

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, 'pact:verify:monolith_no_pact_helper','pact:verify:monolith', 'pact:verify:monolith_ssl', 'pact:verify:middleware']
