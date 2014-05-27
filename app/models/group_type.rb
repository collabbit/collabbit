class GroupType < ActiveRecord::Base
  include Authority
  acts_as_archive
  
  belongs_to :instance
  has_many :groups, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, :within => 2..32
  
  attr_accessible :name

  # used for defining a subset of groups to be included in select options
  attr_accessor :selected_groups

  def self.grouptypes_arr(instance)
    group_types = instance.group_types.find(:all)
    group_types
  end

  def self.export_model(instance)
    group_types = grouptypes_arr(instance)
    result_group_types = group_types.to_yaml
    result_group_types.gsub!(/\n/,"\r\n")
    result_group_types
  end
  
  def self.model_arri(dest)
     GroupType
     Dir.chdir(dest)
     @grouptypesfile = Dir.glob("*"+self.name.pluralize + ".yml")
     yfgrouptypes = File.open(@grouptypesfile.to_s)
     grouptypes = YAML.load(yfgrouptypes)
     grouptypes  
  end
  
  def self.import_model(instance, dest)
    grouptypes = self.model_arri(dest)
    grouptypes.each do |grt|
        grtype = instance.group_types.build(:name => "#{grt.name}", :groups_count => "#{grt.groups_count}")
      instance.save
     end
  end

end
