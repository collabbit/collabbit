class WhitelistedDomain < ActiveRecord::Base
  include Authority

  belongs_to :instance
  inherits_permissions_from :instance
  
  def self.whitelisteddomainsarr(instance)
    whitelisted_domains = instance.whitelisted_domains.find(:all)
    whitelisted_domains 
  end
  
  def self.export_whitelisted_domains(instance)
    whitelisted_domains = whitelisteddomainsarr(instance)
    result_whitelisted_domains = whitelisted_domains.to_yaml
    result_whitelisted_domains.gsub!(/\n/,"\r\n")
    result_whitelisted_domains
  end
end
