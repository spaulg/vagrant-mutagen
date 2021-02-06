require_relative "../mutagen"
require_relative "../ssh"

module VagrantPlugins
  module MutagenProject
    module Action
      class RemoveConfig
        include Mutagen
        include Ssh

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend
              if machine_action != :halt
                if is_enabled
                  @ui.info "[vagrant-mutagen-project] Removing SSH config entry"
                  remove_config_entries
                end
              end
            end
          end
          @app.call(env)
        end
      end
    end
  end
end
