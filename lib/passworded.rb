module Passworded
  require 'digest/sha1'
  
  # Generates a 40-character psuedo-random hex string
  def make_token
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s)
  end
  
  # Sets a random salt
  def generate_salt!
    salt = make_token
  end
  
  # Generates the properly encrypted password
  def generate_crypted_password(plaintext = password)
    Digest::SHA1.hexdigest(plaintext + salt) if plaintext && salt
  end
  
  def generate_crypted_password!(plaintext = password)
    crypted_password = generate_crypted_password(plaintext)
  end
  
  def password_matches?(plaintext)
    crypted_password == generate_crypted_password(plaintext)
  end
  
  # Reencrypt passwords
  def before_update
    if !@password.blank? && @password_confirmation == @password
      generate_crypted_password!(@password)
    end
  end
  
end