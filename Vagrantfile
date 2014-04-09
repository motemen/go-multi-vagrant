require 'yaml'

MACHINES = YAML.load_file('machines.yaml')

Vagrant.configure('2') do |config|
  config.omnibus.chef_version = :latest

  MACHINES.each do |name, machine|
    config.vm.define name do |config|
      config.vm.box = machine['box']

      config.vm.hostname = [ name, 'vagrant', %x(uname -n).chomp ].join('.')

      config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = '.vendor/cookbooks'
        chef.run_list = [
          'recipe[golang]',
          'recipe[build-essential]',
        ]
        chef.json = {
          go: {
            gopath: '/home/vagrant/.go',
            owner: 'vagrant',
            group: 'vagrant',
            platform: machine['platform']
          }
        }
      end

      config.vm.provision :shell, inline: 'chown -R vagrant:vagrant /home/vagrant/.go/src'

      config.vm.synced_folder '.', '/home/vagrant/.go/src/github.com/motemen/go-multi-vagrant'
    end
  end
end
