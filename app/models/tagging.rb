class Tagging < ActiveRecord::Base
  include Authority
  
  belongs_to :tag
  belongs_to :update
  
  def self.taggingsarr(instance)
    tags = Tag.tagsarr(instance)
    taggings_array = Array.new
      tags.each do |ups|
        taggings = ups.taggings.find(:all)
        taggings_array += taggings
    end
    taggings_array
  end
  
  def self.export_taggings(instance)
    taggings_array = taggingsarr(instance)
    result_taggings = taggings_array.to_yaml
    result_taggings.gsub!(/\n/,"\r\n")
    result_taggings
  end
end
