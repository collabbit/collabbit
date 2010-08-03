class Privilege < ActiveRecord::Base
  include Authority
  belongs_to :role
  belongs_to :permission
  
  inherits_permissions_from :role
end
