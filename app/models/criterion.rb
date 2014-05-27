class Criterion < ActiveRecord::Base
  include Authority
  belongs_to :feed
  
  inherits_permissions_from :feed
  
  def self.criterions_arr(instance)
    feeds = Feed.feeds_arr(instance)
    criterion_array = Array.new
       feeds.each do |fds|
         criterions = fds.criterions.find(:all)  
         criterion_array += criterions
       end
   criterion_array
  end
  
  def self.export_model(instance)
    criterion_array = criterions_arr(instance)
    result_criterions = criterion_array.to_yaml
    result_criterions.gsub!(/\n/,"\r\n")
    result_criterions
  end
  
  def self.model_arri(dest)
    Criterion
    Dir.chdir(dest)
    @criterionsfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfcriterions = File.open(@criterionsfile.to_s)
    criterions = YAML.load(yfcriterions)
    criterions
  end
  
  def self.import_model(instance, dest)
    criterions = self.model_arri(dest)
    feeds = Feed.model_arri(dest)
    ydocs = Incident.model_arri(dest)
    criterions.each do |crt|
      ct = -1
      feeds.each do |fd|
        ct += 1
        break if fd.id == crt.feed_id
      end
      
      ic = -1
      ydocs.each do |inc|
      ic += 1
        break if inc.id == feeds[ct].incident_id
      end
      
      @incd = instance.incidents.find_by_name(ydocs[ic].name.to_s)
      @fed = @incd.feeds.find_by_name(feeds[ct].name.to_s)
      criter = @fed.criterions.build(:kind => "#{crt.kind}", :requirement => "#{crt.requirement}", :requirement => "#{crt.requirement}")
      @fed.save
    end
  end
end
