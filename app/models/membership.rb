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
  
  def self.membershipsarr(instance)
    users = User.usersarr(instance)
    mem_array = Array.new
      users.each do |us|
        memberships = us.memberships.find(:all)
        mem_array += memberships
    end
    mem_array
  end
  
  def self.export_memberships(instance)
    mem_array = membershipsarr(instance)
    result_memberships = mem_array.to_yaml
    result_memberships.gsub!(/\n/,"\r\n")
    result_memberships
  end
  
end
