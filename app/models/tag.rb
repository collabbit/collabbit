# Provides a model for tags
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
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
end
