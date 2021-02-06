require "vagrant-mutagen-project/action/start_mutagen_project"
require "vagrant-mutagen-project/action/pause_mutagen_project"
require "vagrant-mutagen-project/action/resume_mutagen_project"
require "vagrant-mutagen-project/action/terminate_mutagen_project"
require "yaml"

module VagrantPlugins
  module MutagenProject
    class Plugin < Vagrant.plugin('2')
      name 'Mutagen-Project'
      description <<-DESC
        This plugin manages the ~/.ssh/config file for the host machine. An entry is
        created for the hostname attribute in the vm.config.
      DESC

      config(:mutagen) do
        require_relative 'config'
        Config
      end

      action_hook(:mutagen, :machine_action_up) do |hook|
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartMutagenProject)
      end

      action_hook(:mutagen, :machine_action_destroy) do |hook|
        hook.after(Vagrant::Action::Builtin::DestroyConfirm, Action::TerminateMutagenProject)
      end

      action_hook(:mutagen, :machine_action_halt) do |hook|
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::PauseMutagenProject)
      end

      action_hook(:mutagen, :machine_action_suspend) do |hook|
        hook.before(VagrantPlugins::HyperV::Action::SuspendVM, Action::PauseMutagenProject)
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::Suspend, Action::PauseMutagenProject)
      end

      action_hook(:mutagen, :machine_action_reload) do |hook|
        hook.before(Vagrant::Action::Builtin::GracefulHalt, Action::PauseMutagenProject)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::ResumeMutagenProject)
      end

      action_hook(:mutagen, :machine_action_resume) do |hook|
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::ResumeMutagenProject)
      end
    end
  end
end
