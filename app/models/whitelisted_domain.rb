class WhitelistedDomain < ActiveRecord::Base
  include Authority

  belongs_to :instance
  inherits_permissions_from :instance
  
  def self.whitelisted_domains_arr(instance)
    whitelisted_domains = instance.whitelisted_domains.find(:all)
    whitelisted_domains 
  end
  
  def self.export_model(instance)
    whitelisted_domains = whitelisted_domains_arr(instance)
    result_whitelisted_domains = whitelisted_domains.to_yaml
    result_whitelisted_domains.gsub!(/\n/,"\r\n")
    result_whitelisted_domains
  end
  
  def self.model_arri(dest)
      WhitelistedDomain
      Dir.chdir(dest)
      @whitelisteddomainsfile = Dir.glob("*"+self.name.pluralize + ".yml")
      yfwhitelisteddomains = File.open(@whitelisteddomainsfile.to_s)
      whitelisteddomains = YAML.load(yfwhitelisteddomains)
      whitelisteddomains
  end
  
  def self.import_model(instance, dest)
      whitelisteddomains = self.model_arri(dest)
      whitelisteddomains.each do |wld|
       instance.whitelisted_domains.build(:name => "#{wld.name}")
       instance.save
      end
  end
  
end
