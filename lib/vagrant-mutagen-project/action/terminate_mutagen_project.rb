require_relative "../mutagen"
require_relative "../ssh_config"

module VagrantPlugins
  module MutagenProject
    module Action
      class TerminateMutagenProject
        include Mutagen
        include SSHConfig

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if is_enabled && is_destroy_confirmed(env)
            terminate_project

            @ui.info "[vagrant-mutagen-project] Removing SSH config entry"
            remove_config_entries
          end

          @app.call(env)
        end

        def is_destroy_confirmed(env)
          env[:force_confirm_destroy_result]
        end
      end
    end
  end
end