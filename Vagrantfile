Vagrant.configure(2) do |config|
  # Machine 1
  config.vm.define "node1" do |node|
    node.vm.box = "ubuntu/focal64"
    node.vm.hostname = "vagrant-mutagen-node1"

    # Automatically provision mutagen to synchronise files
    # in to the VM
    node.mutagen.orchestrate = true
    node.mutagen.project_file = "mutagen-node1.yml"
  end

  # Machine 2
  config.vm.define "node2" do |node|
    node.vm.box = "ubuntu/focal64"
    node.vm.hostname = "vagrant-mutagen-node2"

    # Automatically provision mutagen to synchronise files
    # in to the VM
    node.mutagen.orchestrate = true
    node.mutagen.project_file = "mutagen-node2.yml"
  end

  # Machine 3
  config.vm.define "node3" do |node|
    node.vm.box = "ubuntu/focal64"
    node.vm.hostname = "vagrant-mutagen-node3"

    # Automatically provision mutagen to synchronise files
    # in to the VM
    node.mutagen.orchestrate = true
    node.mutagen.project_file = "mutagen-node3.yml"
  end
end
