# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'authority'
require 'set'
require 'csv'

def flatten_keys(hsh, prefix='')
  hsh.to_a.inject({}) do |memo, pair|
    k,v = pair
    if v.is_a? Hash
      flatten_keys(v, "#{prefix}#{k}.").each_pair do |a,b|
        memo[a] = b
      end
      memo
    else
      memo["#{prefix}#{k}"] = v
      memo
    end
  end
end

SETTINGS = flatten_keys YAML.load_file('config/settings/keys.yml')

Rails::Initializer.run do |config|
  
  config.active_record.observers = :user_observer, :update_observer
  config.active_record.colorize_logging = false
  
  config.gem 'vpim'
  config.gem 'exceptional'
  config.gem 'searchlogic'
  config.gem 'fastimage', :lib => 'fastimage'
  config.gem 'acts_as_archive'
  config.gem 'rubyzip', :lib => 'zip/zip'
  config.gem 'rack-rewrite'

  require 'rack-rewrite'
  config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
    maintenance_file = File.join(RAILS_ROOT, 'public', 'system', 'maintenance.html')
    send_file /.*/, maintenance_file, :if => Proc.new { |rack_env|
      File.exists?(maintenance_file) && rack_env['REQUEST_URI'] !~ /\.(css|jpg|png)/
    }
  end
    
  config.action_controller.session = {
     :session_key => SETTINGS['action_controller.session.session_key'],
     :secret      => SETTINGS['action_controller.session.secret']
   }
   
   config.action_mailer.default_url_options = {
     :host => SETTINGS['host.base_url']
   }
   
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:std => "%m/%d/%Y")