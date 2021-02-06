require "vagrant-mutagen-project/version"
require "vagrant-mutagen-project/plugin"

module VagrantPlugins
  module MutagenProject
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
