class Tag < ActiveRecord::Base
  include Authority
  
  has_many :taggings, :dependent => :destroy
  has_many :updates, :through => :taggings
  
  has_many :group_taggings, :dependent => :destroy
  has_many :groups, :through => :group_taggings

  belongs_to :instance

  validates_each do |model, attr, value|
    if attr == :name and Tag.exists?({:instance_id => self.instance_id, :name => value})
      model.error.add(attr,"must be unique")
    end
  end
  
  def self.tags_arr(instance)
    tags = instance.tags.find(:all)
    tags
  end
  
  def self.export_model(instance)
    tags = tags_arr(instance)
    result_tags = tags.to_yaml
    result_tags.gsub!(/\n/,"\r\n")
    result_tags
  end
  
  def self.model_arri(dest)
    Tag
    Dir.chdir(dest)
    @tagsfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yftags = File.open(@tagsfile.to_s)
    tags = YAML.load(yftags)
    tags
  end
  
  def self.import_model(instance, dest)
    tags = self.model_arri(dest)
    tags.each do |tgs|
       instance.tags.build(:name => "#{tgs.name}")
       instance.save
    end
  end
  
  validates_length_of :name, :within => 1..64
  validates_presence_of :name
  
end
