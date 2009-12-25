# A join model between users and groups
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Membership < ActiveRecord::Base
  include Authority
  belongs_to :group
  belongs_to :user
  
  owned_by :user
  
  #validates_associated :group
  #validates_associated :user
  
  validates_uniqueness_of :user_id, :scope => :group_id
  
  def chair?
    is_chair
  end
  
end
