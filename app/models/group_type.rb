# Represents a collection of groups. For example, agencies or committees.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class GroupType < ActiveRecord::Base
  include Authority
  belongs_to :instance
  has_many :groups, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, :within => 2..32
  
  attr_accessible :name
  
end
