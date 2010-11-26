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
  
  def self.groups_arr(instance)
      groups_array =Array.new
      group_types = GroupType.grouptypes_arr(instance)
      group_types.each do |grp|
        groups = grp.groups.find(:all)
        groups_array += groups
    end
    groups_array
  end
  
  def self.export_model(instance)
    groups_array = groups_arr(instance)
    result_groups = groups_array.to_yaml
    result_groups.gsub!(/\n/,"\r\n")
    result_groups
  end
  
  def self.model_arri(dest)
    Group
    Dir.chdir(dest)
    @groupsfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfgroups = File.open(@groupsfile.to_s)
    groups = YAML.load(yfgroups)
    groups
  end
  
  def self.import_model(instance, dest)
    groups = self.model_arri(dest)
    grouptypes = GroupType.model_arri(dest)
    groups.each do |grps|
       ct = -1
       grouptypes.each do |typ|
         ct += 1
         break if grps.group_type_id == typ.id
        end
    
    group_type = instance.group_types.find_by_name(grouptypes[ct].name.to_s)
    group = group_type.groups.build(:name => "#{grps.name}")
    group_type.save
    end
  end
  
  protected
    def clear_user(user)
      memberships.find_all_by_user_id(user.id).each {|m| m.destroy}
    end
    
end
