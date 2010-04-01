settings = YAML.load_file("config/settings/smtp.yml")[ENV['RAILS_ENV'] || 'production']

smtp_setting_keys = {
  :enable_starttls_auto => 'tls',
  :address              => 'address',
  :port                 => 'port',
  :domain               => 'domain',
  :user_name            => 'username',
  :password             => 'password',
  :authentication       => 'authentication'
} 

ActionMailer::Base.smtp_settings = {}

smtp_setting_keys.each_pair do |k, v|
  if settings.include?(v) && !settings[v].blank?
    ActionMailer::Base.smtp_settings[k] = settings[v]
  end
end