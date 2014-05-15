# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # sensu-server
  config.vm.define :server001 do |server|
    server.vm.hostname = "server001.foobar.com"
    server.vm.box      = "CentOS6.5-x86_64"
    server.vm.box_url  = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
    server.vm.network :private_network, ip: "192.168.33.10"
    server.vm.provider :virtualbox do |vb|
      vb.gui = false
   
      # Use VBoxManage to customize the VM. For example to change memory:
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    server.vm.provision :shell, :inline => <<-EOT
      sh /vagrant/sensu-server/00-sensu-server-bootstrap.sh
      puppet apply /vagrant/sensu-server/01-redis.pp
      puppet apply /vagrant/sensu-server/02-rabbitmq.pp
      puppet apply /vagrant/sensu-server/03-sensu-server.pp
    EOT
  end

  # sensu-client
  config.vm.define :client001 do |server|
    server.vm.hostname = "client001.foobar.com"
    server.vm.box      = "CentOS6.5-x86_64"
    server.vm.box_url  = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
    server.vm.network :private_network, ip: "192.168.33.200"
    server.vm.provider :virtualbox do |vb|
      vb.gui = false
   
      # Use VBoxManage to customize the VM. For example to change memory:
      vb.customize ["modifyvm", :id, "--memory", "512"]
    end

    server.vm.provision :shell, :inline => <<-EOT
      sh /vagrant/sensu-client/00-sensu-client-bootstrap.sh
      puppet apply /vagrant/sensu-client/01-sensu-client.pp
    EOT
  end

end
