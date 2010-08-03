class Incident < ActiveRecord::Base
  include Authority
  belongs_to :instance
  has_many :updates, :dependent => :destroy
  has_many :feeds, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of   :name, :within => 2..32
  
  attr_accessible :name, :description, :closed
  
  def closed?
    closed_at != nil
  end
  
  def viewable_by?(user)
    instance.viewable_by?(user)
  end

end
