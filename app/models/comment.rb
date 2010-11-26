class Comment < ActiveRecord::Base
  include Authority
  acts_as_archive
  
  belongs_to :update
  belongs_to :user
  
  validates_presence_of :body
  validates_length_of :body, :within => 2..4096

  def self.comments_arr(instance)
    updates = Update.updates_arr(instance)
      comments_array = Array.new
      updates.each do |ups|
        comments=ups.comments.find(:all)
        comments_array +=comments
      end
    comments_array
  end
    
 def self.export_model(instance)
    comments_array =   comments_arr(instance)
    result_comments = comments_array.to_yaml
    result_comments.gsub!(/\n/,"\r\n")
    result_comments 
  end

def self.model_arri(dest)
     Comment
     Dir.chdir(dest)
     @commentsfile = Dir.glob("*"+self.name.pluralize + ".yml")
     yfcomments = File.open(@commentsfile.to_s)
     comments = YAML.load(yfcomments)
     comments
end

def self.import_model(instance, dest)
  updates = Update.model_arri(dest)
  incidents = Incident.model_arri(dest)
  users = User.model_arri(dest)
  comments = self.model_arri(dest)
  comments.each do |cmt|
       cmtt = nil
       elem = -1
       updates.each do |upd|
         elem += 1
         cmtt = upd
         break if upd.id == cmt.update_id
       end
       
       ele = -1
       incidents.each do |comm|
         ele += 1
         break if cmtt.incident_id == comm.id
       end
        
        use = -1
       users.each do |uss|
         use += 1
         break if cmt.user_id == uss.id
       end
       
       user_rec = instance.users.find_by_email(users[use].email.to_s)
       
       @incident = instance.incidents.find_by_name(incidents[ele].name.to_s)
       @update = @incident.updates.find_by_title(updates[elem].title.to_s)
       
       commnt = @update.comments.build(:body => "#{cmt.body}")
       if(user_rec != nil)
          commnt.user_id = user_rec.id
          commnt.save
       end
       @update.save
    end
end

end
