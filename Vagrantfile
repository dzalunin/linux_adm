# -*- mode: ruby -*-
# vim: set ft=ruby :


Hosts =
[
  {
    :name        => "raid-create",
    :box         => "centos/stream8",
    :ram         => 1024,
    :cpus        => 2,
    :disks       =>
    [
        {
            :name   => "large",
            :size   => 250,
            :count  => 5
        },
        {
            :name   => "small",
            :size   => 100,
            :count  => 1
        }
    ]    
  }
]

Vagrant.configure("2") do |config|
    Hosts.each do |host|
        config.vm.synced_folder ".", "/vagrant", disabled: true
  
        config.vm.define host[:name] do |hostconfig|
            hostconfig.vm.box         = host[:box]
            hostconfig.vm.host_name   = host[:name]

            hostconfig.vm.provider "virtualbox" do |vb|
                vb.memory = host[:ram]
                vb.cpus   = host[:cpus]

                vb.customize ["modifyvm", :id, "--audio", "none" ]
                vb.customize ["modifyvm", :id, "--usb", "off" ]

                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                
                $port = 1
                host[:disks].each do |disk|
                    (1..disk[:count]).each do |num|
                        $dfile = "./#{disk[:name]}-sata-0#{num}.vdi"

                        unless File.exist?($dfile)
                            vb.customize ['createhd', '--filename', $dfile, '--variant', 'Fixed', '--size', "#{disk[:size]}"]
                        end

                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', $port, '--device', 0, '--type', 'hdd', '--medium', $dfile]

                        $port = $port + 1
                    end
                end    
            end

            config.vm.provision "Shell", type: "shell" do |s|            
                s.path = "./scripts/init.sh"                 
            end         
        end  
    end  
end