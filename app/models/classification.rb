class Classification < ActiveRecord::Base
  include Authority
  belongs_to :group
  belongs_to :update
  
  def self.classifications_arr(instance)
    group_types = GroupType.grouptypes_arr(instance)
    groups = Group.groups_arr(instance)
    classif_array = Array.new
     group_types.each do |grp|
         groups = grp.groups.find(:all)
          groups.each do |classify|
            classif_array += classify.classifications.find(:all)
        end
    end
    classif_array
  end
  
  def self.export_model(instance)
    classif_array = classifications_arr(instance)
    result_classifications = classif_array.to_yaml
    result_classifications.gsub!(/\n/,"\r\n")
    result_classifications
  end
  
  def self.model_arri(dest)
    Classification
    Dir.chdir(dest)
    @classiffile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfclassifs = File.open(@classiffile.to_s)
    classifications = YAML.load(yfclassifs)
    classifications 
  end
  
  def self.import_model(instance,dest)
    classifications = model_arri(dest)
    groups = Group.model_arri(dest)
    grouptypes = GroupType.model_arri(dest)
    updates = Update.model_arri(dest)
    ydocs = Incident.model_arri(dest)
    classifications.each do |classif|
    ct = -1
      groups.each do |grp|
        ct += 1
        break if grp.id == classif.group_id
      end
    
      count = -1
      grouptypes.each do |gtype|
        count +=1
        break if gtype.id == groups[ct].group_type_id
      end
 
      cnt = -1
      updates.each do |upd|
        cnt += 1
        break if upd.id == classif.update_id
      end
    
      cntt = -1
      ydocs.each do |inci|
          cntt += 1
          break if inci.id == updates[cnt].incident_id
      end
    
    grptype = instance.group_types.find_by_name(grouptypes[count].name.to_s)
    group = grptype.groups.find_by_name(groups[ct].name.to_s)
    
    incident = instance.incidents.find_by_name(ydocs[cntt].name.to_s)
    upd = incident.updates.find_by_title(updates[cnt].title.to_s)
    group.classifications.build(:update_id => "#{upd.id}")
    group.save
    end
  end
end
