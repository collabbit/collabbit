# Represents a unique, brandable, sandboxed version of the site for a specific organization or purpose
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Instance < ActiveRecord::Base
  has_many :incidents, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :group_types, :dependent => :destroy
  has_many :groups, :through => :group_types
  has_many :roles
  has_many :tags, :dependent => :destroy
  
  validates_length_of :long_name,  :within => 4..255
  validates_format_of :short_name, :with => /\A[a-z]+\z/
  validates_length_of :short_name, :within => 2..16
  validates_uniqueness_of :short_name
  validates_exclusion_of  :short_name,
                          :in => %w( support blog www billing help api internal mail ),
                          :message => "The name <strong>{{value}}</strong> is reserved and unavailable."

  # Allows us to use the short_name in the URL instead of the ID
  def to_param
    short_name
  end
  
  # All of the updates in an instance
  def updates
    ups = []
    incidents.each {|i| ups += i.updates}
    ups
  end
  
  def viewable?
    User.current.instance == self || super
  end
  
  # Overwrites find so that <tt>Instance.find(x.to_param)</tt> works
  def self.find(*args)
    if args.length == 1 and args.first.is_a?(String)
      super(:first, :conditions => {:short_name => args.first})
    else
      super(*args)
    end
  end
end
