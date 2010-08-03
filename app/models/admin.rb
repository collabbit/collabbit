require 'digest/sha1'

class Admin < ActiveRecord::Base
  include Authority, Passworded
  attr_accessor :password, :password_confirmation
  attr_accessible :email
  
  @@current = nil
  mattr_accessor :current
  
  validates_presence_of :email
  validates_length_of   :email, :within => 6..100
  validates_format_of   :email, :with => /\A([\w\.\-\+]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
