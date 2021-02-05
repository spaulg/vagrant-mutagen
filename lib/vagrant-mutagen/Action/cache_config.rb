require_relative "../mutagen"
require_relative "../ssh"

module VagrantPlugins
  module Mutagen
    module Action
      class CacheConfig
        include Mutagen
        include Ssh

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          if is_enabled
            cache_config_entries
          end
          @app.call(env)
        end
      end
    end
  end
end
