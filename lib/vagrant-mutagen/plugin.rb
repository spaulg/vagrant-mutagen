require "vagrant-mutagen/Action/update_config"
require "vagrant-mutagen/Action/cache_config"
require "vagrant-mutagen/Action/remove_config"
require "vagrant-mutagen/Action/start_mutagen"
require "vagrant-mutagen/Action/terminate_mutagen"

module VagrantPlugins
  module Mutagen
    class Plugin < Vagrant.plugin('2')
      name 'Mutagen'
      description <<-DESC
        This plugin manages the ~/.ssh/config file for the host machine. An entry is
        created for the hostname attribute in the vm.config.
      DESC

      config(:mutagen) do
        require_relative 'config'
        Config
      end

      action_hook(:mutagen, :machine_action_up) do |hook|
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartMutagen)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
      end

      action_hook(:mutagen, :machine_action_halt) do |hook|
        hook.append(Action::TerminateMutagen)
        hook.append(Action::RemoveConfig)
      end

      action_hook(:mutagen, :machine_action_suspend) do |hook|
        hook.append(Action::TerminateMutagen)
        hook.append(Action::RemoveConfig)
      end

      action_hook(:mutagen, :machine_action_destroy) do |hook|
        hook.prepend(Action::CacheConfig)
        hook.append(Action::TerminateMutagen)
        hook.append(Action::RemoveConfig)
      end

      action_hook(:mutagen, :machine_action_reload) do |hook|
        hook.append(Action::TerminateMutagen)
        hook.prepend(Action::RemoveConfig)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartMutagen)
      end

      action_hook(:mutagen, :machine_action_resume) do |hook|
        hook.append(Action::TerminateMutagen)
        hook.prepend(Action::RemoveConfig)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::UpdateConfig)
        hook.after(Vagrant::Action::Builtin::WaitForCommunicator, Action::StartMutagen)
      end
    end
  end
end
