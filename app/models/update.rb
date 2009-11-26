# Represents an update, the core piece of data within the application
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Update < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :incident
  belongs_to :issuing_group, :class_name => 'Group', :foreign_key => 'group_id'
  
  has_many :classifications
  has_many :relevant_groups, :through => :classifications, :class_name => 'Group', :source => :group
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :attachments, :dependent => :destroy
  
  validates_presence_of :title
  validates_length_of   :title, :within => 3..256
  validates_presence_of :text
  validates_length_of   :text, :within => 1..1000000
  
  attr_accessor :additional_tags
  after_save :handle_tags
   
  attr_protected :incident, :incident_id
  
  # def created_at
  #   @created_at
  # end
  # def updated_at
  #   @updated_at
  # end
  
  def viewable_by?(u)
    user == u || super
  end
  def updatable_by?(u)
    user == u || super
  end
  def destroyable_by?(u)
    user == u || super
  end
  
  # Returns the issuing type as a symbol
  def issuing_type
     if issuing_group 
       :group
     else
       :user
     end
  end
 
  # Returns the issuer
  def issuer
    self.issuing_group || self.user  
  end
  
  # Sets the issuer
  def issuer=(i)
    if i.is_a? Group
      self.issuing_group = i
    else
      self.issuing_group = nil
    end
  end
  
  # Gets an array of all attached file paths
  def files
    self.attachments.map {|a| a.attach.url }
  end
  
  # Setter for additional tags. Tags aren't actually added until handle_tags is called.
  def additional_tags=(tags)
    @new_tags = tags
  end
  
  # There shouldn't be any additional tags. They should always be turned into real tags.
  # However, if the Update doesn't get saved, handle_tags won't be called, so we need
  # to repopulate the additional tags field.
  def additional_tags
    @new_tags
  end
  
  private
    # Turns @new_tags (array of tag names) into real tags and taggings
    def handle_tags
      return unless @new_tags
      @new_tags.split(',').each do |t|
        t.strip!
        tag = self.incident.instance.tags.find_by_name(t)
        if tag
          self.tags << tag unless tags.include?(tag) # This seems to create and save a tagging
        else 
          self.tags.create(:name => t, :instance => incident.instance)
        end
      end
    end
   
end
