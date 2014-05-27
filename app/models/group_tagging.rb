class GroupTagging < ActiveRecord::Base
  include Authority
  belongs_to :tag
  belongs_to :group
  
  def self.grouptaggings_arr(instance)
    groups = Group.groups_arr(instance)
    gt_array = Array.new
        groups.each do |grp|
            gtags = grp.group_taggings.find(:all)
            gt_array += gtags
        end
    gt_array
  end
  
  def self.export_model(instance)
    gt_array = grouptaggings_arr(instance)
    result_group_taggings = gt_array.to_yaml
    result_group_taggings.gsub!(/\n/,"\r\n")
    result_group_taggings
  end
  
  def self.model_arri(dest)
    GroupTagging
    Dir.chdir(dest)
    @grouptaggingsfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfgrouptaggings = File.open(@grouptaggingsfile.to_s)
    grouptaggings = YAML.load(yfgrouptaggings)
    grouptaggings
  end
  
  def self.import_model(instance, dest)
      grouptaggings = self.model_arri(dest)
      tags = Tag.model_arri(dest)
      groups = Group.model_arri(dest)
      grouptypes = GroupType.model_arri(dest)
      grouptaggings.each do |gtg|
      ele = -1
      tags.each do |ts|
        ele += 1
        break if ts.id == gtg.tag_id
      end
      
      gp = -1
      groups.each do |gps|
        gp += 1
        break if gps.id == gtg.group_id
      end
      
      elem = -1
        grouptypes.each do |grty|
          elem +=1
          break if grty.id == groups[gp].group_type_id
        end
      
      @grptyp = instance.group_types.find_by_name(group_types[elem].name.to_s)
      grp = @grptyp.groups.find_by_name(groups[gp].name.to_s)
      
      @tag = instance.tags.find_by_name(tags[ts].name.to_s)
      group_type = @tag.group_taggings.build(:group_id => "#{grp.id}")
      @tag.save
    end
  end
end
