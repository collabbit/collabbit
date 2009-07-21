# Represents a set of permissions that users can have
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Role < ActiveRecord::Base
  has_many :users
  belongs_to :instance

  has_many :privileges, :dependent => :destroy
  has_many :permissions, :through => :privileges
  
  validates_presence_of :name
  validates_length_of   :name, :within => 2..32
  
  # Returns the default role.
  def self.default
    #TODO: eventually, move this setting into the database under Instance, maybe
    find_by_name DEFAULT_ROLE_NAME
  end
  
end