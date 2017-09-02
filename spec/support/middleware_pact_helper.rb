require 'pact/provider/rspec'

Pact.provider_states_for "a consumer" do
  provider_state "some state" do
    no_op
  end
end

class Middleware

  DATE_PATTERN = /\d\d\d\d\-\d\d-\d\d/

  def initialize app
    @app = app
  end

  def call env
    x_expiry = env['HTTP_X_EXPIRY']
    if x_expiry =~ DATE_PATTERN
      set_dynamic_expiry env
      @app.call(env)
    else
      error_response(x_expiry)
    end
  end

  def set_dynamic_expiry env
    dynamic_expiry = (DateTime.now + 1).strftime('%Y-%m-%d')
    puts "Setting dynamic expiry to #{dynamic_expiry}"
    env['HTTP_X_EXPIRY'] = dynamic_expiry
  end

  def error_response x_expiry
    error_message = "Error replaying request. Expected X-Expiry header to match #{DATE_PATTERN.inspect} but actual value was #{x_expiry.inspect}"
    [500, {}, [error_message]]
  end
end

reverse_proxy = Pact.configuration.provider.app

Pact.service_provider "Running Service Provider" do
  app { Middleware.new(reverse_proxy) }
end
