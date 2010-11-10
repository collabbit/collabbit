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

  def self.grouptypesarr(instance)
    group_types = instance.group_types.find(:all)
    group_types
  end

  def self.export_group_types(instance)
    group_types = grouptypesarr(instance)
    result_group_types = group_types.to_yaml
    result_group_types.gsub!(/\n/,"\r\n")
    result_group_types
  end

end
