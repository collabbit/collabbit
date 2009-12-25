# A join model between roles and permissions.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Privilege < ActiveRecord::Base
  include Authority
  belongs_to :role
  belongs_to :permission
  
  inherits_permissions_from :role
end