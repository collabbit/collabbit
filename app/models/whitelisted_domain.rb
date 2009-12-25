class WhitelistedDomain < ActiveRecord::Base
  include Authority

  belongs_to :instance
  inherits_permissions_from :instance
  
end
