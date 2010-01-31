settings = YAML.load_file("config/smtp.yml")[ENV['RAILS_ENV'] || 'production']

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => settings['tls'],
  :address        => settings['address'],
  :port           => settings['port'] || 25,
  :domain         => settings['domain'],
  :authentication => settings['authentication'].to_sym if settings['authentication'],
  :user_name      => settings['username'],
  :password       => settings['password']
}

