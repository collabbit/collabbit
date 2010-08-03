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
