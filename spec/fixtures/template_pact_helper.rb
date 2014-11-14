require 'pact/provider/rspec'

Pact.provider_states_for "a consumer" do
  provider_state "some state" do
    no_op
  end
end
