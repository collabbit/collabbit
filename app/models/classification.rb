class Classification < ActiveRecord::Base
  include Authority
  belongs_to :group
  belongs_to :update
  
  def self.classificationsarr(instance)
    group_types = GroupType.grouptypesarr(instance)
    groups = Group.groupsarr(instance)
    classif_array = Array.new
     group_types.each do |grp|
         groups = grp.groups.find(:all)
          groups.each do |classify|
            classif_array += classify.classifications.find(:all)
        end
    end
    classif_array
  end
  
  def self.export_classifications(instance)
    classif_array = classificationsarr(instance)
    result_classifications = classif_array.to_yaml
    result_classifications.gsub!(/\n/,"\r\n")
    result_classifications
  end
end
