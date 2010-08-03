class Criterion < ActiveRecord::Base
  include Authority
  belongs_to :feed
  
  inherits_permissions_from :feed
end
