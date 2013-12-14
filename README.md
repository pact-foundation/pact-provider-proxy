# Pact::Proxy

Allows pact verification against a running provider at a configurable base URL (normal pact verification is run against a code base using Rack::Test::Methods - no process is actually spawned).

This allows testing against providers where you have access to a running instance of a provider, but you do not have access to its code base, or where the provider is not a ruby application.

## Installation

Add this line to your application's Gemfile:

    gem 'pact-proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pact-proxy

## Usage

Usually, you would configure and run pact:verify in the provider code base.
If you are using a pact-proxy to run your pact verify task, it is probably because you don't have access to the code base of the provider project, or it is not a ruby project, so it may make sense to include this task in your consumer project.

Specifying a pact_helper is optional, and is only required if you are using provider states.

```ruby
require 'pact/provider/proxy/tasks'

Pact::ProxyVerificationTask.new :monolith do | task |
 task.pact_url './spec/pacts/my-consumer_my-monolith.json', :pact_helper => './spec/support/monolith_pact_helper'
 task.provider_base_url 'http://my-monolith'
end
```

Then run:

    $ rake pact:verify:monolith

If you have access to your provider code base, and are able to spawn an instance locally, you could add some rake tasks to start and stop your server. (Please note, I have actually run this code, I just think it should work...)

```ruby

Pact::ProxyVerificationTask.new :running_local_monolith do | task |
 task.pact_url './spec/pacts/my-consumer_my-local-monolith.json'
 task.provider_base_url 'http://localhost:8080'
end

task :start_provider do
  system "./provider_start -p 8080"
end

task :stop_provider do
  system "./provider_stop"
end

task 'pact:verify:local_monolith' do
  begin
    Rake::Task['start_provider'].execute
    Rake::Task['pact:verify:running_local_monolith'].execute
  ensure
    Rake::Task['stop_provider'].execute
  end
end

```

If a ruby adapter to the underlying datastore cannot be used to set up provider states, shell scripts that invoke code in the native language might work. If you have access to the code base, another alternative could be to provide an endpoint on your app that sets up data inside itself, that is only mounted in test mode. eg 'http://localhost:8080/setUpProviderState?name=a%20thing%20exists' and 'http://localhost:8080/tearDownProviderState?name=a%20thing%20exists'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
