require "shellwords"

module VagrantPlugins
  module MutagenProject
    module SSHConfig
      SSH_CONFIG_PATH = File.expand_path('~/.ssh/config')

      def sudo(command)
        return unless command

        if Vagrant::Util::Platform.windows?
          require 'win32ole'

          args = command.split(" ")
          command = args.shift
          sh = WIN32OLE.new('Shell.Application')
          sh.ShellExecute(command, args.join(" "), '', 'runas', 0)
        else
          system("sudo #{command}")
        end
      end

      def add_config_entries
        # Prepare some needed variables
        uuid = @machine.id
        name = @machine.name
        hostname = @machine.config.vm.hostname

        # Read contents of SSH config file
        file = File.open(SSH_CONFIG_PATH, "rb")
        config_contents = file.read

        # Check for existing entry for hostname in config
        entry_pattern = config_entry_pattern(hostname, name, uuid)
        if config_contents.match(/#{entry_pattern}/)
          @ui.info "[vagrant-mutagen-project]   updating SSH Config entry for: #{hostname}"
          remove_config_entries
        else
          @ui.info "[vagrant-mutagen-project]   adding entry to SSH config for: #{hostname}"
        end

        # Get SSH config from Vagrant
        newconfig = create_config_entry(hostname, name, uuid)

        # Append vagrant ssh config to end of file
        add_to_ssh_config(newconfig)
      end

      def add_to_ssh_config(content)
        return if content.length == 0

        @ui.info "[vagrant-mutagen-project] Writing the following config to (#{SSH_CONFIG_PATH})"
        @ui.info content

        if !File.writable_real?(SSH_CONFIG_PATH)
          @ui.info "[vagrant-mutagen-project] This operation requires administrative access. You may " +
                       "skip it by manually adding equivalent entries to the config file."

          unless sudo(%Q(sh -c 'echo "#{content}" >> #{SSH_CONFIG_PATH}'))
            @ui.error "[vagrant-mutagen-project] Failed to add config, could not use sudo"
          end
        elsif Vagrant::Util::Platform.windows?
          require 'tmpdir'
          uuid = @machine.id
          tmp_path = File.join(Dir.tmpdir, 'hosts-' + uuid + '.cmd')

          File.open(tmp_path, "w") do |tmpFile|
            tmpFile.puts(">>\"#{SSH_CONFIG_PATH}\" echo #{content}")
          end

          sudo(tmp_path)
          File.delete(tmp_path)
        else
          content = "\n" + content + "\n"

          hosts_file = File.open(SSH_CONFIG_PATH, "a")
          hosts_file.write(content)
          hosts_file.close
        end
      end

      # Create a regular expression that will match the vagrant-mutagen signature
      def config_entry_pattern(hostname, name, uuid = self.uuid)
        hashed_id = Digest::MD5.hexdigest(uuid)
        Regexp.new("^# VAGRANT: #{hashed_id}.*$\nHost #{hostname}.*$")
      end

      def create_config_entry(hostname, name, uuid = self.uuid)
        # Get the SSH config from Vagrant
        shell_name = Shellwords.escape(name)
        shell_hostname = Shellwords.escape(hostname)
        sshconfig = `vagrant ssh-config #{shell_name} --host #{shell_hostname}`

        # Trim Whitespace from end
        sshconfig = sshconfig.gsub /^$\n/, ''
        sshconfig = sshconfig.chomp

        # Return the entry
        %Q(#{signature(name, uuid)}\n#{sshconfig}\n#{signature(name, uuid)})
      end

      def remove_config_entries
        unless @machine.id
          @ui.info "[vagrant-mutagen-project] No machine id, nothing removed from #{SSH_CONFIG_PATH}"
          return
        end

        file = File.open(SSH_CONFIG_PATH, "rb")
        config_contents = file.read
        uuid = @machine.id

        hashed_id = Digest::MD5.hexdigest(uuid)
        if config_contents.match(/#{hashed_id}/)
          remove_from_config
        end
      end

      def remove_from_config(options = {})
        uuid = @machine.id
        hashed_id = Digest::MD5.hexdigest(uuid)

        if !File.writable_real?(SSH_CONFIG_PATH) || Vagrant::Util::Platform.windows?
          unless sudo(%Q(sed -i -e '/# VAGRANT: #{hashed_id}/,/# VAGRANT: #{hashed_id}/d' #{SSH_CONFIG_PATH}))
            @ui.error "[vagrant-mutagen-project] Failed to remove config, could not use sudo"
          end
        else
          hosts = ""
          pair_started = false
          pair_ended = false

          File.open(SSH_CONFIG_PATH).each do |line|
            # Reset
            if pair_started && pair_ended
              pair_started = pair_ended = false
            end

            if line.match(/#{hashed_id}/)
              if pair_started
                pair_ended = true
              end
              pair_started = true
            end

            hosts << line unless pair_started
          end

          hosts.strip!
          hosts_file = File.open(SSH_CONFIG_PATH, "w")
          hosts_file.write(hosts)
          hosts_file.close
        end
      end

      def signature(name, uuid = self.uuid)
        hashed_id = Digest::MD5.hexdigest(uuid)
        %Q(# VAGRANT: #{hashed_id} (#{name}) / #{uuid})
      end
    end
  end
end
