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
  
  def self.feeds_arr(instance)
    feeds_array = Array.new
      incidents = Incident.incidents_arr(instance)
      incidents.each do |fed|
        feeds = fed.feeds.find(:all)
        feeds_array += feeds
    end
    feeds_array
  end
  
  def self.export_model(instance)
    feeds_array = feeds_arr(instance)
    result_feeds = feeds_array.to_yaml
    result_feeds.gsub!(/\n/,"\r\n")
    result_feeds
  end
  
  def self.model_arri(dest)
    Feed
    Dir.chdir(dest)
    @feedsfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yffeeds = File.open(@feedsfile.to_s)
    feeds = YAML.load(yffeeds)
    feeds
  end
  
  def self.import_model(instance, dest)
    feeds = self.model_arri(dest)
    users = User.model_arri(dest)
    ydocs = Incident.model_arri(dest)
    
    feeds.each do |fds|
      fd = -1
      ydocs.each do |ins|
        fd += 1
        break if fds.incident_id == ins.id
      end
      
      u = -1
      users.each do |us|
        u += 1
        break if us.id = fds.owner_id
      end
   
    userr = instance.users.find_by_email(users[u].email.to_s)
    
    
    @incid = instance.incidents.find_by_name(ydocs[fd].name.to_s)
    feed = @incid.feeds.build(:name => "#{fds.name}", 
                              :description => "#{fds.description}", 
                              :text_alert => "#{fds.text_alert}",
                              :email_alert => "#{fds.email_alert}",
                              :owner_id => "#{userr.id}")
    @incid.save
   
    end
  end
  
end
