require 'pact/provider/proxy/task_helper'

module Pact
  module Provider
    module Proxy
      describe TaskHelper do

        include TaskHelper

        let(:pact_helper) { './pact_helper.rb' }
        let(:pact_uri) { 'http://pact.com/pact.json' }
        let(:command) { verify_command pact_helper, pact_uri }

        before do
          allow(ENV).to receive(:[]).with('PACT_DESCRIPTION').and_return('desc ription')
          allow(ENV).to receive(:[]).with('PACT_PROVIDER_STATE').and_return('state')
          allow(ENV).to receive(:[]).with('BACKTRACE').and_return('true')
        end

        describe "#verify_command" do
          context "when the PACT_DESCRIPTION is set" do
            it "includes the --description option" do
              expect(command).to include " --description desc\\ ription "
            end
          end

          context "when the PACT_PROVIDER_STATE is set" do
            it "includes the --provider-state option" do
              expect(command).to include " --provider-state state "
            end
          end

          context "when the BACKTRACE is set" do
            it "includes the --backtrace option" do
              expect(command).to include " --backtrace"
            end
          end
        end
      end
    end
  end
end
