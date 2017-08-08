require 'rack/reverse_proxy'
require 'rack/test'

module Rack
  describe ReverseProxy do
    include Rack::Test::Methods

    before(:all) do
      @pipe = IO.popen("ruby spec/support/echoing_server.rb")
      sleep 2
    end

    after(:all) do
      Process.kill 'KILL', @pipe.pid
    end

    let(:app) do
      Rack::ReverseProxy.new do
        reverse_proxy '/', 'http://localhost:2000'
      end
    end

    it 'somehow converts all caps header names into properly capitalized headers' do
      get '/', nil, {'HTTP_FOO_BAR' => 'wiffle' }
      expect(last_response.body).to include('Foo-Bar: wiffle')
    end
  end
end
