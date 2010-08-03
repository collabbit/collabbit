class Group < ActiveRecord::Base
  include Authority
  acts_as_archive
    
  belongs_to :group_type, :counter_cache => true
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
  
  attr_protected :group_type_id

  # Checks if a specified user has permission to update a group; 
  # If he is the chair, he will have permission.
  def updatable_by?(user)
    chairs.include?(user)
  end
  
  def viewable_by?(user)
    user.groups.include?(self)
  end
  
  protected
    def clear_user(user)
      memberships.find_all_by_user_id(user.id).each {|m| m.destroy}
    end
    
end
