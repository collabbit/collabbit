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
end
