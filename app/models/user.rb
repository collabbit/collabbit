class User < ActiveRecord::Base
  include Authority, Passworded

  acts_as_archive

  belongs_to :role
  belongs_to :instance
  belongs_to :carrier
  has_many :updates
  has_many :groups, :through => :memberships
  
  has_many :feeds, :foreign_key => 'owner_id', :dependent => :destroy
  accepts_nested_attributes_for :feeds
  
  has_many :memberships, :dependent => :destroy, :uniq => true
  has_many :comments, :dependent => :destroy

  before_validation_on_create :default_alert_settings

  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100
  validates_uniqueness_of   :email, :scope => :instance_id
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_inclusion_of    :text_alert, :in => [true,false]
  validates_inclusion_of    :email_alert,:in => [true,false]

  attr_accessor :password_confirmation, :password
  
  # Makes sure that no security holes are exposed during mass assignment.
  attr_accessible :first_name,    :last_name,       :email,
                  :desk_phone,    :cell_phone,      :preferred_is_cell,
                  :wants_alerts,  :desk_phone_ext,  :password,
                  :password_confirmation,           :carrier,
                  :carrier_id,    :feeds_attributes,:state,
                  :text_alert,    :email_alert
  
  def can?(hsh)
    return false unless hsh.is_a?(Hash) && role != nil
    hsh.each_pair do |action, obj|
      trans = {:view => :show, :delete => :destroy}
      action = trans[action] if trans.include? action
      if (!obj.is_a?(Array)) && obj.requires_override?
        return false unless permission_to?(action, obj) && override_for?(action, obj)
      else
        unless permission_to?(action, obj) || override_for?(action, obj)
          return false
        end
      end
    end
    return true
  end
  
  def permission_to?(action, obj)
    if obj.is_a? Array
      if obj.empty?
        true
      else
        obj.collect {|o| permission_to? action, o}.inject {|l,r| l && r}
      end
    else
      klass = obj.class == Class ? obj : obj.class
      role.permissions.exists? :model => klass.to_s, :action => action.to_s
    end
  end
  
  def override_for?(action, obj)
    case action
      when :show
        obj.viewable_by? self
      when :list
        obj.inject(true) {|res, e| res && e.viewable_by?(self) }
      when :destroy
        obj.destroyable_by? self
      when :update
        if obj.is_a? Array
          obj.inject(true) {|res, e| res && e.updatable_by?(self)}
        else
          obj.updatable_by? self
        end
      else
        false
    end
  end
  
  def viewable_by?(usr)
    self == usr
  end
  def updatable_by?(usr)
    self == usr && state == 'active'
  end
  def destroyable_by?(usr)
    self == usr
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
      desk_phone.to_s + " x" + desk_phone_ext
    else
      desk_phone
    end
  end
  
  def cell_phone?
    !cell_phone.blank?
  end
  def desk_phone?
    !desk_phone.blank?
  end
  def preferred_is_cell?
    preferred_is_cell
  end
  
  # check if a user receives text/email alerts
  def text_alert?
    text_alert
  end
  def email_alert?
    email_alert
  end
  def text_alerts?
    text_alert
  end
  def email_alerts?
    email_alert
  end
  
  # Gets the user's permissions
  def permissions
    (role && role.permissions) || []
  end
  
  # Returns an array of the groups that the user chairs
  def chaired_groups
    (memberships.select {|m| m.is_chair}).map {|m| m.group}
  end
  
  # Combines the user's cell phone and their carrier into one string
  def text_email
    cell_phone.gsub(/[^0-9]/, '')+carrier.extension
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
      if self.groups.size > 0
        maker.org = self.groups.map(&:name)
      end
    end
    
  end
  
  def active?
    self.state == 'active'
  end
  def approved?
    self.state == 'approved'
  end
  def pending?
    self.state == 'pending'
  end
  def activate!
    self.state = 'active'
    self.activated_at = DateTime.now
    self.save(false)
	# Send later to delayed job
    UserMailer.send_later :deliver_activation, self
  end
  def approve!
    self.state = 'approved'
    self.save(false)
  end
  def can_log_in?
    active? || approved?
  end
  
  def generate_activation_code!
    self.activation_code = make_token
  end
  
  def whitelisted?
    instance.whitelisted_domains.exists?(:name => self.email.split('@').last.downcase)
  end
  
  # Generates and saves a new remember token
  def refresh_token
    if remember_token?
      self.remember_token = make_token
      save(false)
    end    
  end
  
  # Generates a new remember token and sets the expiry to 2 weeks in the future
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now
    self.remember_token = make_token
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
  
  def save_without_observers
    UserObserver.disable!
    save
    UserObserver.enable!
  end

  private
    def default_alert_settings
      self.email_alert ||= true
      self.text_alert  ||= false
      self
    end
end
