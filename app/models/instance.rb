# Represents a unique, brandable, sandboxed version of the site for a specific organization or purpose
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Instance < ActiveRecord::Base
  has_many :incidents, :dependent => :destroy
  has_many :updates, :through => :incidents
  has_many :users, :dependent => :destroy
  has_many :feeds, :through => :user
  has_many :group_types, :dependent => :destroy
  has_many :groups, :through => :group_types
  has_many :roles, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :whitelisted_domains, :dependent => :destroy
  
  attr_writer :whitelisted_domain_names
  after_save :handle_whitelisted_domains
  
  validates_length_of :long_name,  :within => 4..255
  validates_format_of :short_name, :with => /\A[a-z]+\z/
  validates_length_of :short_name, :within => 2..16
  validates_uniqueness_of :short_name
  validates_exclusion_of  :short_name,
                          :in => %w( support blog www billing help api internal mail ),
                          :message => "The name <strong>{{value}}</strong> is reserved and unavailable."


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
  
  def viewable?
    (User.current && User.current.instance == self) || super
  end
  
  # Overwrites find so that <tt>Instance.find(x.to_param)</tt> works
  def self.find(*args)
    if args.length == 1 and args.first.is_a?(String)
      super(:first, :conditions => {:short_name => args.first})
    else
      super(*args)
    end
  end

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
