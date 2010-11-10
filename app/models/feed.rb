class Feed < ActiveRecord::Base
  include Authority
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :incident
  
  has_many :updates, :through => :incident
  has_many :criterions, :dependent => :destroy
  
  validates_presence_of :name
  
  owned_by :owner
  
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
          (update.relevant_groups & owner.groups).size > 0 if owner
        when 'user'
          update.user_id == c.requirement
      end
    end
    return true
  end
  
  def self.make_my_groups_feed(incident)
    mine = Feed.new(:name => 'My Groups', :description => '', 
      :incident => incident, :text_alert => false, :email_alert => true)
    mine.criterions.build(:kind => 'user_group')
    mine
  end
  
  def self.feedsarr(instance)
    feeds_array = Array.new
      incidents = Incident.incidentsarr(instance)
      incidents.each do |fed|
        feeds = fed.feeds.find(:all)
        feeds_array += feeds
    end
    feeds_array
  end
  
  def self.export_feeds(instance)
    feeds_array = feedsarr(instance)
    result_feeds = feeds_array.to_yaml
    result_feeds.gsub!(/\n/,"\r\n")
    result_feeds
  end
  
  
end
