# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.ssh.forward_agent = true
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, ip: "192.168.33.2"
  config.vm.provision "shell" do |s|
    s.inline     = "bash /vagrant/setup.sh"
    s.privileged = false
  end
end
