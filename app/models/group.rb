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
  
  def self.groupsarr(instance)
      groups_array =Array.new
      group_types = GroupType.grouptypesarr(instance)
      group_types.each do |grp|
        groups = grp.groups.find(:all)
        groups_array += groups
    end
    groups_array
  end
  
  def self.export_groups(instance)
    groups_array = groupsarr(instance)
    result_groups = groups_array.to_yaml
    result_groups.gsub!(/\n/,"\r\n")
    result_groups
  end
  
  protected
    def clear_user(user)
      memberships.find_all_by_user_id(user.id).each {|m| m.destroy}
    end
    
end
