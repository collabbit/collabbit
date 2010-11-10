class GroupTagging < ActiveRecord::Base
  include Authority
  belongs_to :tag
  belongs_to :group
  
  def self.grouptaggingsarr(instance)
    groups = Group.groupsarr(instance)
    gt_array = Array.new
        groups.each do |grp|
            gtags = grp.group_taggings.find(:all)
            gt_array += gtags
        end
    gt_array
  end
  
  def self.export_group_taggings(instance)
    gt_array = grouptaggingsarr(instance)
    result_group_taggings = gt_array.to_yaml
    result_group_taggings.gsub!(/\n/,"\r\n")
    result_group_taggings
  end
end
