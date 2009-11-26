# Represents a criterion for a feed
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Criterion < ActiveRecord::Base
  belongs_to :feed
  
  def creatable_by?(user)
    owner_check(user) || super
  end
  def deletable_by?(user)
    owner_check(user) || super
  end
  def updatable_by?(user)
    owner_check(user) || super
  end
  
  private
    def owner_check(user)
      feed.owner == user
    end
end
