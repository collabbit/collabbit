# Provides a model for site-wide administrators. Note that while these are not
# actual users, in many places the logic dealing with them is quite similar.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
require 'digest/sha1'

class Admin < ActiveRecord::Base
  include Authority
  attr_accessor :password, :password_confirmation
  @@current = nil
  mattr_accessor :current
  
  # Generates the properly encrypted password
  def generate_crypted_password(plaintext = password)
    Digest::SHA1.hexdigest(plaintext + salt) if plaintext && salt
  end
  
  # Reencrypt passwords
  def before_update
    self.crypted_password = generate_crypted_password(@password) if @password
  end
   
end
