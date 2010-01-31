settings = YAML.load_file("config/smtp.yml")[ENV['RAILS_ENV'] || 'production']

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => settings['tls'],
  :address        => settings['address'],
  :port           => settings['port'] || 25,
  :domain         => settings['domain'],
  :user_name      => settings['username'],
  :password       => settings['password']
}

if settings.include? 'authentication' && !settings['authentication'].blank?
  ActionMailer::Base.smtp_settings[:authentication] = settings['authentication'].to_sym
end


