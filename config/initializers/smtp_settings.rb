settings = YAML.load_file("config/smtp.yml")[ENV['RAILS_ENV'] || 'production']

ActionMailer::Base.smtp_settings = 

keys = {
  :enable_starttls_auto => 'tls',
  :address              => 'address',
  :port                 => 'port',
  :domain               => 'domain',
  :user_name            => 'username',
  :password             => 'password'
}

keys.each_pair do |k, v|
  if settings.include? v && !settings[v].blank?
    ActionMailer::Base.smtp_settings[k] = settings[v]
  end
end