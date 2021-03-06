require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @translator = Helpers::Translator.new("actions.destroy")
        end

        def call(env)
          # submit destroy droplet request
          result = @client.request("/droplets/#{@machine.id}/destroy")

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(env, result["event_id"])

          # set the machine id to nil to cleanup local vagrant state
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
