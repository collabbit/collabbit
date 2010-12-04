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
 
 def updates_tag_filter(tag)
   @filtered_updates = []
   self.updates.each do |u|
     @tags = u.tags.find(:all)
     for i in (0..(@tags.size-1)) do
        @tags[i] = @tags[i].name
     end
     if !tag || @tags.include?(tag)
       @filtered_updates << u
     end
   end
   @filtered_updates
 end
 
 def updates_group_filter(group)
   @filtered_updates = []
   self.updates.each do |u|
     @groups = u.relevant_groups.find(:all)
     for i in (0..@groups.size-1) do
       @groups[i] = @groups[i].name
     end
     if !group || @groups.include?(group)
       @filtered_updates << u
     end
   end
   @filtered_updates
 end
 
 def updates_search_filter(query)
   if query && query.size>0
     query = query.gsub(/ +/, " ").split(' ')
     @results = self.updates.title_or_text_like_any(query)
   else
     @results = self.updates.find(:all)
   end
 end
  
  def viewable_by?(user)
    instance.viewable_by?(user)
  end
end
