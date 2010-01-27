module Passworded
  require 'digest/sha1'
  
  # Generates the properly encrypted password
  def generate_crypted_password(plaintext = password)
    Digest::SHA1.hexdigest(plaintext + salt) if plaintext && salt
  end
  
  # Reencrypt passwords
  def before_update
    if !@password.blank? && @password_confirmation == @password
      self.crypted_password = generate_crypted_password(@password)
    end
  end
  
end