require_relative "../mutagen"

module VagrantPlugins
  module MutagenProject
    module Action
      class ResumeMutagenProject
        include Mutagen

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if is_enabled
            @ui.info "[vagrant-mutagen-project] Resuming Mutagen sync"
            resume_project
          end

          @app.call(env)
        end
      end
    end
  end
end
