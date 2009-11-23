# Represents a group of a group type within an instance
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Group < ActiveRecord::Base
    
  belongs_to :group_type
  has_many :memberships, :dependent => :destroy, :uniq => true
  has_many :users, :through => :memberships
  has_many :chairs, :class_name => 'User',
    :through => :memberships, :source => :user, :conditions => 'is_chair = 1', :before_add => :clear_user
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
    def clear_user(user)
      memberships.find_all_by_user_id(user.id).each {|m| m.destroy}
    end
    
end
