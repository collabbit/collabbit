# gem required: sudo gem install capistrano-ext

def load_settings(env)
  set_settings(YAML.load_file("config/settings/deploy.yml")[env.to_s])
end

def set_settings(params)
  params.each_pair do |k,v|
    set k.to_sym, v
    puts "Setting #{k} to #{v}"
  end
  if exists? :domain
    role :app, domain
    role :web, domain
    role :db,  domain, :primary => true
  end
end

def configuration_for(name, settings = {})
  settings[:path], settings[:filename] = File.split(settings[:filepath]) if settings[:filepath]
  settings[:path] ||= "config/settings"
  settings[:chmod] = 775 unless settings.key? :chmod
  
  after 'deploy:update_code', "#{name}:symlink"
  before 'deploy:setup', name.to_sym
  namespace(name.to_sym) do    
    desc "Configuration for #{name}"
    task(:default) do
      set(:shared_dir) { File.join(fetch(:shared_path), settings[:path]) }
      set(:shared_file) { File.join(fetch(:shared_dir), settings[:filename]) } if settings[:filename]
      run "mkdir -p #{shared_dir}"
      run "chmod #{settings[:chmod]} #{shared_dir}" if settings[:chmod]
      if settings[:filename]
        settings[:text] = yield if block_given?
        puts settings[:text], shared_file
        run "chmod #{settings[:chmod]} #{shared_file}"
      elsif block_given?
        yield
      end
    end
    # Same as foo.gsub /\/\z/, '', probably
    sym_path = File.join(File.split("#{settings[:path]}/#{settings[:filename]}"))
    symlink_task name, sym_path, :chmod => settings[:chmod]
  end
end

def symlink_task(nspace, path, settings = {})
  settings[:chmod] = 775 unless settings.key? :chmod
  desc "Create the symlink for #{File.basename(path)}"
  namespace(nspace.to_sym) do
    task(:symlink) do
      from = File.join(fetch(:shared_path), path)
      to = File.join(fetch(:release_path), path)
      run "mkdir -p #{File.dirname(to)}"
      run "chmod #{settings[:chmod]} #{File.dirname(to)}" if settings[:chmod]
      run "ln -nfs #{from} #{to}"
    end
  end
end

set :stages, %w(staging production)
require 'capistrano/ext/multistage'
set :application, 'collabbit'

set :use_sudo,    false
set :scm,         :git
set :deploy_via,  :remote_cache

# set :git_shallow_clone, 1

ssh_options[:paranoid] = false
default_run_options[:pty] = true

before 'deploy:restart', :gems
  
namespace :passenger do

  desc "Restarts your application server."
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Starts the application servers." 
  task :start, :roles => :app do
    logger.info ":start task not supported by Passenger server"
  end
  
  desc "Stops the application servers."
  task :stop, :roles => :app do
    logger.info ":stop task not supported by Passenger server"
  end

end


namespace :deploy do

  desc <<-DESC
    Restarts your application. \
    Overwrites default :restart task for Passenger server.
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    passenger.restart
  end
  
  desc <<-DESC
    Starts the application servers. \
    Overwrites default :start task for Passenger server.
  DESC
  task :start, :roles => :app do
    passenger.start
  end
  
  desc <<-DESC
    Stops the application servers. \
    Overwrites default :start task for Passenger server.
  DESC
  task :stop, :roles => :app do
    passenger.stop
  end
end


configuration_for :db, :filepath => 'config/database.yml' do
  set(:db_user) { Capistrano::CLI.ui.ask 'Database Username: ' }
  set(:db_pass) { Capistrano::CLI.password_prompt 'Database Password: ' }

  <<-EOF
  production:
    database: #{production_database}
    adapter: mysql
    encoding: utf8
    username: #{db_user}
    password: #{db_pass}
    
  development:
    database: #{development_database}
    adapter: mysql
    encoding: utf8
    username: #{db_user}
    password: #{db_pass}
  EOF
end

configuration_for :exceptional, :filepath => 'config/exceptional.yml' do
  set :api_key do
    Capistrano::CLI.ui.ask 'Exceptional API key?'
  end
  
  exceptional_data = {
    'production' => {
      'api-key' => api_key,
      'enabled' => true
    }
  }.to_yaml
end

configuration_for :mail, :filepath => 'config/settings/smtp.yml' do
  {'production' => {
      'port'     => 25,
      'domain'   => 'collabbit.org',
      'address'  => 'localhost',
      'tls'      => false,
      'authentication' => false
    }
  }.to_yaml
end

configuration_for :keys, :filepath => 'config/settings/keys.yml' do
  {'action_controller' => {
      'session' => {
        'session_key' => '_collabbit-001-staging',
        'secret' => '5695f525eb5ec94353765d4c12c64df56cadc68bb8ba49a1bb1967379bccfd994176645f677d7568cc114bf2f94b'
      }
    }
  }.to_yaml
end

configuration_for :attachments, :path => 'attachments'

namespace :gems do
  desc "Update gems"
  task :default do
    run "cd #{release_path} && rake gems:install && rake gems:unpack"
  end
end

namespace :db do
  desc 'Migrate production database'
  task :migrate do
    run "cd #{release_path} && rake db:migrate RAILS_ENV=production"
  end
end