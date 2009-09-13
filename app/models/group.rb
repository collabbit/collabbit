# Represents a group of a group type within an instance
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Group < ActiveRecord::Base
    extend ActiveSupport::Memoizable
    
  belongs_to :group_type
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :chairs, :class_name => 'User',
    :through => :memberships, :source => :user, :conditions => 'is_chair = 1', :after_add => :chairize
  has_many :classifications, :dependent => :destroy
  has_many :updates, :through => :classifications
  has_many :group_taggings
  has_many :tags, :through => :group_tagging
  
  validates_presence_of :name
  validates_associated  :group_type
  validates_uniqueness_of :name, :scope => :group_type_id

  # Checks if a specified user has permission to update a group; 
  # If he is the chair, he will have permission.
  def updatable?
    chairs.include?(User.current) || super
  end
  
  def viewable?
    User.current.groups.include?(self) || super
  end
  
  protected
    def chairize(user)
      m = memberships.find_all_by_user_id(user.id)
      if m.size > 1
        for x in 1..(m.size-1)
          m[x].destroy
        end
      end
      m[0].is_chair = true
      m[0].save
    end
    
end
