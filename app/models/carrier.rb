# Represents a phone carrier
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Carrier < ActiveRecord::Base
  include Authority
  
  validates_presence_of :name, :extension
  validates_length_of :name, :within => 1..64
  validates_length_of :extension, :within => 1..64
  
  attr_accessible :name, :extension
  
end
