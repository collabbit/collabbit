# Represents an action that a user might need authorization to access 
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Permission < ActiveRecord::Base
  include Authority
  
  has_many :privileges, :dependent => :destroy
  has_many :roles, :through => :privileges

end
