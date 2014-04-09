require 'yaml'

ALL_MACHINES = YAML.load_file('machines.yaml').keys.join(' ')

task :default => [:init, 'vagrant:make']

desc 'Initialize required tools (required once, a bit slow)'
task :init do
  sh 'vagrant', 'plugin', 'install', 'vagrant-omnibus'
end

desc 'Setup required libraries'
task :setup do
  sh 'bundle', 'install', '--quiet'
  sh 'bundle', 'exec', 'berks', 'install', '--path=.vendor/cookbooks'
end

namespace :vagrant do
  desc 'Run make on virtual machines'
  task :make, [:machine, :target] => [:up, :make_fast]

  desc 'Start virtual machines'
  task :up, [:machine] => [:setup] do |t,args|
    prepare_args! args
    args.machines.each do |machine|
      sh 'vagrant', 'up', machine
    end
  end

  desc 'Run make without starting up machines'
  task :make_fast, [:machine, :target] do |t,args|
    prepare_args! args
    threads = args.machines.map do |machine|
      sleep 0.5
      Thread.new do
        puts "---> Running on #{machine}"
        sh 'vagrant', 'ssh', machine, '--', '$SHELL', '-l', '-c', %Q('cd /vagrant && make #{args.target} 2>&1 | sed "s/^/[#{machine}] /"')
      end
    end
    threads.each { |t| t.join }
  end

  desc 'Watch local files to invoke make on virtual machines'
  task :watch, [:machine, :target] do |t,args|
    require 'listen'
    require 'pathname'

    prepare_args! args
    ios = args.machines.map do |machine|
      puts "---> Listening to changes on #{machine}"
      sleep 0.5 # wait slightly for vagrant starting
      IO.popen([
        'vagrant', 'ssh', machine, '--', '$SHELL', '-l', '-c', %Q('cd /vagrant && while read x; do echo "[#{machine}] make #{args.target}"; make #{args.target} 2>&1 | sed "s/^/[#{machine}] /"; done')
      ], 'w')
    end

    listener = Listen.to('.') do |m,a,r|
      puts "---> Files changed: #{(m+a+r).map { |p| Pathname.new(p).relative_path_from(Pathname.pwd) }.join(' ')}"
      ios.each { |io| io.puts }
    end
    listener.only /\.go$/
    listener.start

    trap 'INT' do
      ios.each do |io|
        Process.kill 'KILL', io.pid
      end

      exit
    end

    sleep
  end

  def prepare_args!(args)
    args.with_defaults(
      :target => ENV['TARGET'],
      :machines => ENV.reject { |k,v| v.empty? }.fetch('MACHINE', ALL_MACHINES).split(/[, ]+/)
    )
  end
end
