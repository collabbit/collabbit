# Represents an update, the core piece of data within the application
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Update < ActiveRecord::Base
  include Authority
  
  belongs_to :user
  belongs_to :incident
  belongs_to :issuing_group, :class_name => 'Group', :foreign_key => 'group_id'
  
  has_many :classifications
  has_many :relevant_groups, :through => :classifications, :class_name => 'Group', :source => :group
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :attached_files, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  validates_presence_of :title
  validates_length_of   :title, :within => 3..256
  validates_presence_of :text
  validates_length_of   :text, :within => 1..1000000
  
  attr_accessor :additional_tags
  after_save :handle_tags
  attr_protected :incident_id, :user_id
  
  owned_by :user
  
  # Returns the issuing type as a symbol
  def issuing_type
     issuing_group ? :group : :user
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
      self.issuing_group = nil #<<FIX: is this the right behavior?
    end
  end
  
  # Gets an array of all attached file paths
  def file_urls
    self.attached_files.map {|a| a.attach.url }
  end
  
  def attached_files?
    self.attached_files.empty?
  end
  
  def attachments
    attached_files
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
