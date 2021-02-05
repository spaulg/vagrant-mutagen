require "shellwords"

module VagrantPlugins
  module Mutagen
    module Mutagen
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

      def is_enabled()
        @machine.config.mutagen.orchestrate == true
      end

      def start_daemon()
        daemon_command = "mutagen daemon start"

        unless system(daemon_command)
          @ui.error "[vagrant-mutagen] Failed to start mutagen daemon"
        end
      end

      def start_project()
        project_file = @machine.config.mutagen.project_file
        start_daemon

        project_started_command = "mutagen project list -f %s >/dev/null 2>/dev/null" % [Shellwords.escape(project_file)]
        project_start_command = "mutagen project start -f %s" % [Shellwords.escape(project_file)]
        project_status_command = "mutagen project list -f %s" % [Shellwords.escape(project_file)]

        unless system(project_started_command) # mutagen project list returns 1 on error when no project is started
          @ui.info "[vagrant-mutagen] Starting mutagen project orchestration (config: %s)" % project_file

          unless system(project_start_command)
            @ui.error "[vagrant-mutagen] Failed to start mutagen project (see error above)"
          end
        end

        system(project_status_command) # show project status to indicate if there are conflicts
      end

      def terminate_project()
        project_file = @machine.config.mutagen.project_file

        project_started_command = "mutagen project list -f %s >/dev/null 2>/dev/null" % [Shellwords.escape(project_file)]
        project_terminate_command = "mutagen project terminate -f %s" % [Shellwords.escape(project_file)]
        project_status_command = "mutagen project list -f %s 2>/dev/null" % [Shellwords.escape(project_file)]

        if system(project_started_command) # mutagen project list returns 1 on error when no project is started
          @ui.info "[vagrant-mutagen] Stopping mutagen project orchestration"

          unless system(project_terminate_command)
            @ui.error "[vagrant-mutagen] Failed to stop mutagen project (see error above)"
          end
        end

        system(project_status_command)
      end
    end
  end
end
