class Carrier < ActiveRecord::Base
  include Authority
  
  validates_presence_of :name, :extension
  validates_length_of :name, :within => 1..64
  validates_length_of :extension, :within => 1..64
  
  attr_accessible :name, :extension
  
end
