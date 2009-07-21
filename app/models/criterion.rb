# Represents a criterion for a feed
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Criterion < ActiveRecord::Base
  belongs_to :feed
  
  def creatable?
    owner_check || super
  end
  def deletable?
    owner_check || super
  end
  def updatable?
    owner_check || super
  end
  
  private
    def owner_check
      feed.owner == User.current
    end
end
