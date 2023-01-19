# -*- mode: ruby -*-
# vim: set ft=ruby :
ENV["LC_ALL"] = "en_US.UTF-8"
HDPATH = File.join(ENV['HOME'], 'VirtualBox VMs')

Hosts =
[
  {
    :name        => "lvm",
    :box         => "centos/7",
    :box_version => "1804.02",
    :ram         => 1024,
    :cpus        => 2,
    :disks       =>
    [
        {:size => 10240, :count => 1},
        {:size => 2048,  :count => 1},
        {:size => 1024,  :count => 2}
    ]    
  }
]

Vagrant.configure("2") do |config|
    Hosts.each do |host|
        config.vm.synced_folder ".", "/vagrant", disabled: true
  
        config.vm.define host[:name] do |hostconfig|
            hostconfig.vm.box         = host[:box]
            hostconfig.vm.box_version = host[:box_version]
            hostconfig.vm.host_name   = host[:name]

            hostconfig.vm.provider "virtualbox" do |vb|
                vb.memory = host[:ram]
                vb.cpus   = host[:cpus]

                vb.customize ["modifyvm", :id, "--audio", "none" ]
                vb.customize ["modifyvm", :id, "--usb", "off" ]

                port = 1
                host[:disks].each do |disk|
                    for _ in 1..disk[:count]
                        dfile = File.join(HDPATH, "sata-#{port}.vdi")

                        unless File.exist?(dfile)
                            vb.customize ['createhd', '--filename', dfile, '--variant', 'Fixed', '--size', "#{disk[:size]}"]
                            
                            if port == 1
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                            end    
                        end

                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', port, '--device', 0, '--type', 'hdd', '--medium', dfile]

                        port = port + 1
                    end
                end
            end

            config.vm.provision "Shell", type: "shell" do |s|            
                s.path = "./scripts/init.sh"                 
            end         
        end  
    end  
end

