require 'yaml';
class Instance < ActiveRecord::Base 
  include Authority
  
  FORBIDDEN_SUBDOMAINS = %w( support blog www billing help api internal mail email webmail )
  
  acts_as_archive
  
  has_many :incidents, :dependent => :destroy
  has_many :updates, :through => :incidents
  has_many :users, :dependent => :destroy
  has_many :feeds, :through => :users
  has_many :group_types, :dependent => :destroy
  has_many :groups, :through => :group_types
  has_many :roles, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :whitelisted_domains, :dependent => :destroy
  
  attr_writer :whitelisted_domain_names
  after_save :handle_whitelisted_domains
  
  validates_presence_of :short_name, :long_name
  validates_length_of :long_name,  :within => 4..255
  validates_format_of :short_name, :with => /\A[a-z]+(_[a-z]+)*\z/
  validates_length_of :short_name, :within => 2..16
  validates_uniqueness_of :short_name
  validates_exclusion_of  :short_name,
                          :in => FORBIDDEN_SUBDOMAINS,
                          :message => "The name <strong>{{value}}</strong> is reserved and unavailable."
  
  attr_accessible :whitelisted_domain_names, :long_name

  requires_override!
  def viewable_by?(usr)
    usr.instance == self
  end
  def updatable_by?(usr)
    usr.instance == self
  end
  
  @@current = nil
  mattr_accessor :current
  
  # Allows us to use the short_name in the URL instead of the ID
  def to_param
    short_name
  end
  
  def whitelisted_domain_names
    existing = whitelisted_domains.map {|w| w.name }
    extra = @whitelisted_domain_names || []
    ((existing + extra).map {|w| w.strip}).join("\n")
  end
  
  def viewable_by?(user)
    user && user.instance == self
  end
  
 
  
  # Overwrites find so that <tt>Instance.find(x.to_param)</tt> works
  def self.find(*args)
    if args.length == 1 and args.first.is_a?(String)
      super(:first, :conditions => {:short_name => args.first})
    else
      super(*args)
    end
  end
 
  
  class Missing < RuntimeError; end
  
  private
    def handle_whitelisted_domains
      self.whitelisted_domains.clear
      unless @whitelisted_domain_names == nil
        @whitelisted_domain_names.each do |w|
          self.whitelisted_domains.create(:name => w.strip)
        end
      end
    end
end
