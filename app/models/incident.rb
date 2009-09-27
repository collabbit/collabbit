# Represents an incident within an instance of the application.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Incident < ActiveRecord::Base
  belongs_to :instance
  has_many :updates, :dependent => :destroy
  
  validates_presence_of :description
  validates_length_of   :name, :within => 2..32
  
  def closed?
    closed_at != nil
  end
  
  def viewable?
    User.current.instance.viewable? || super
  end

end
