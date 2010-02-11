# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'authority'

settings = YAML.load_file('config/settings/keys.yml')

Rails::Initializer.run do |config|
  
  config.active_record.observers = :user_observer, :update_observer
  config.active_record.colorize_logging = false
  
  config.gem 'vpim'
  config.gem 'exceptional'
  config.gem 'searchlogic'
  config.gem 'fastimage', :lib => 'fastimage'
  
  config.action_controller.session = {
    :session_key => settings['action_controller']['session']['session_key'],
    :secret      => settings['action_controller']['session']['secret']
  }
  
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:std => "%m/%d/%Y")