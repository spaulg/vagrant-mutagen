require_relative "../mutagen"
require_relative "../ssh"

module VagrantPlugins
  module Mutagen
    module Action
      class TerminateMutagen
        include Mutagen
        include Ssh

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if is_enabled
            terminate_project
          end
          @app.call(env)
        end
      end
    end
  end
end
