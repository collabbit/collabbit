class Permission < ActiveRecord::Base
  include Authority
  
  has_many :privileges, :dependent => :destroy
  has_many :roles, :through => :privileges

end
