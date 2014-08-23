class Criterion < ActiveRecord::Base
  include Authority
  belongs_to :feed
  
  inherits_permissions_from :feed
  
  def self.criterionsarr(instance)
    feeds = Feed.feedsarr(instance)
    criterion_array = Array.new
       feeds.each do |fds|
         criterions = fds.criterions.find(:all)  
         criterion_array += criterions
       end
   criterion_array
  end
  
  def self.export_criterions(instance)
    criterion_array = criterionsarr(instance)
    result_criterions = criterion_array.to_yaml
    result_criterions.gsub!(/\n/,"\r\n")
    result_criterions
  end
end
