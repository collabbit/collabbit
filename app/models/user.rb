# Provides a model for instance-specific users.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

require 'digest/sha1'

class User < ActiveRecord::Base
  
  STATES = {:pending => 'pending', :pending_approval => 'pending_approval', :active => 'active', :deleted => 'deleted'}

  @@current = nil
  mattr_accessor :current
      
  belongs_to :role
  belongs_to :instance
  belongs_to :carrier
  has_many :updates
  has_many :groups, :through => :memberships
  has_many :user_feeds, :class_name => "Feed", :dependent => :destroy
  has_many :memberships, :dependent => :destroy, :uniq => true

  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100
  validates_uniqueness_of   :email, :scope => :instance_id

  attr_accessor :password_confirmation, :password
#  validates_presence_of     :password, :on => :create
#  validates_length_of       :password, :within => 8..64, :on => :create
  
  # Makes sure that no security holes are exposed during mass assignment.
  attr_accessible :first_name,    :last_name,       :email,
                  :desk_phone,    :cell_phone,      :preferred_is_cell,
                  :wants_alerts,  :desk_phone_ext,  :password,
                  :password_confirmation, :carrier, :carrier_id
  
  # Reencrypt passwords
  def before_update
    self.crypted_password = generate_crypted_password(@password) if @password
  end
  
  # Provides a user's full name for convenience
  def full_name
    first_name + " " + last_name
  end
  
  # Returns the name in the format "last, first"
  def last_first
    "#{last_name}, #{first_name}"
  end
  
  # Returns the primary phone.
  def primary_phone
    (preferred_is_cell && cell_phone) || desk_phone_with_ext || cell_phone
  end
  
  # Returns the non-primary phone
  def nonprimary_phone
    (preferred_is_cell && desk_phone_with_ext) || (!preferred_is_cell && cell_phone) || nil
  end
  
  def primary_phone_name
    preferred_is_cell ? 'cell' : 'desk'  
  end
  
  def nonprimary_phone_name
    preferred_is_cell ? 'desk' : 'cell'
  end
  
  # Returns the desk phone with its extension
  def desk_phone_with_ext
    if desk_phone_ext
      desk_phone.to_s + " x " + desk_phone_ext
    else
      desk_phone
    end
  end
  
  # Gets the user's permissions
  def permissions
    (role && role.permissions) || []
  end
  
  # Returns an array of the groups that the user chairs
  def chaired_groups
    (memberships.select {|m| m.is_chair}).map {|m| m.group}
  end
  
  # Generates the properly encrypted password
  def generate_crypted_password(plaintext = password)
    Digest::SHA1.hexdigest(plaintext + salt) if plaintext && salt
  end
  
  # Generates the activation code
  def generate_activation_code
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s)
  end
  
  # Combines the user's cell phone and their carrier into one string
  def text_email
    cell_phone+carrier.format
  end
  
  def to_vcard
    Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.given = first_name
        name.family = last_name
      end
      unless primary_phone.blank?
        maker.add_tel(primary_phone) do |t|
          t.location = primary_phone_name
          t.preferred = true
        end
      end
      unless nonprimary_phone.blank?
        maker.add_tel(nonprimary_phone) {|t| t.location = nonprimary_phone_name}
      end
      maker.add_email(email) if email
    end
    
  end
  
  def active?
    self.state == 'active'
  end
  def activate!
    self.state = 'active'
    self.save(false)
    UserMailer.deliver_activation(self)
  end
  
  ### Tokens ###
  
  # Generates a 40-character psuedo-random hex string
  def self.make_token
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s)
  end
  
  # Generates and saves a new remember token
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token
      save(false)
    end    
  end
  
  # Generates a new remember token and sets the expiry to 2 weeks in the future
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now
    self.remember_token = self.class.make_token
    save(false)
  end
  
  # Removes the expiry and remember tokens from the user
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save(false)
  end
  
  # Returns true if remember token is valid
  def remember_token?
    !remember_token.blank? && remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
  end
  
  ###
  
  def viewable?
    self == User.current || super
  end
  def updatable?
    self == User.current || super
  end
  def destroyable?
    self == User.current || super
  end
end
