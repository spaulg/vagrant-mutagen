require_relative "../mutagen"
require_relative "../ssh"

module VagrantPlugins
  module MutagenProject
    module Action
      class StartMutagenProject
        include Mutagen
        include Ssh

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if is_enabled
            @ui.info "[vagrant-mutagen-project] Checking for SSH config entries"
            add_config_entries
            start_project
          end

          @app.call(env)
        end
      end
    end
  end
end
