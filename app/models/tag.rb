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
  
  validates_length_of :name, :within => 1..64
  validates_presence_of :name
  
end
