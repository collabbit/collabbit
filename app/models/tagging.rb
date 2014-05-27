class Tagging < ActiveRecord::Base
  include Authority
  
  belongs_to :tag
  belongs_to :update
  
  def self.taggings_arr(instance)
    tags = Tag.tags_arr(instance)
    taggings_array = Array.new
      tags.each do |ups|
        taggings = ups.taggings.find(:all)
        taggings_array += taggings
    end
    taggings_array
  end
  
  def self.export_model(instance)
    taggings_array = taggings_arr(instance)
    result_taggings = taggings_array.to_yaml
    result_taggings.gsub!(/\n/,"\r\n")
    result_taggings
  end
  
  def self.model_arri(dest)
      Tagging
      Dir.chdir(dest)
      @taggingsfile = Dir.glob("*"+ self.name + ".yml")
      yftaggings = File.open(@taggingsfile.to_s)
      taggings = YAML.load(yftaggings)
      taggings
  end
  
  def self.import_model(instance, dest)
    taggings = self.model_arri(dest)
    updates = Update.model_arri(dest)
    tags = Tag.model_arri(dest)
    ydocs = Incident.model_arri(dest)
    taggings.each do |tggs|
        tg = -1
        tags.each do |ts|
          tg += 1
          break if ts.id == tggs.tag_id
        end
        
        ti = -1 
        updates.each do |upa|
          ti +=1
          break if upa.id == tggs.update_id
        end
        
        elem = -1
        ydocs.each do |inci|
          elem +=1
          break if inci.id == updates[ti].incident_id
        end
        
        inci= instance.incidents.find_by_name(ydocs[elem].name.to_s)
        upd = inci.updates.find_by_title(updates[ti].title.to_s)
        
        @tag = instance.tags.find_by_name(tags[tg].name.to_s)
        tagging = @tag.taggings.build(:update_id => "#{upd.id}")
        @tag.save
        
       end
  end
end
