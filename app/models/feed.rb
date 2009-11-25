# Represents a set of rules to aggregate updates within an incident
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class Feed < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :incident
  
  has_many :updates, :through => :incident
  has_many :criterions, :dependent => :destroy
  
  validates_presence_of :name
  
  def text_alert?
    text_alert
  end
  def email_alert?
    email_alert
  end

  def filter_updates
    updates.select(&matches)
  end
  
  def matches?(update)
    criterions.each do |c|
      return false unless case c.kind
        when 'start_date'
          Time.parse(c.requirement) <= update.created_at  
        when 'end_date'
          Time.parse(c.requirement) >= update.created_at
        when 'keyword'
          update.text.index(c.requirement) || update.title.index(c.requirement)
        when 'group'
          update.relevant_groups.include?(c.requirement) || update.issuing_group == c.requirement
        when 'user_group'
          (update.relevant_groups & owner.groups).size > 0
        when 'user'
          update.user_id == c.requirement
      end
    end
    return true
  end
  
  def self.make_my_groups_feed(incident)
    mine = Feed.new(:name => 'My Groups', :description => '', 
      :incident => incident, :text_alert => true, :email_alert => true)
    mine.criterions.build(:kind => 'user_group')
    mine
  end
end