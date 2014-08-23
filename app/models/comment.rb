class Comment < ActiveRecord::Base
  include Authority
  acts_as_archive
  
  belongs_to :update
  belongs_to :user
  
  validates_presence_of :body
  validates_length_of :body, :within => 2..4096

  def self.commentsarr(instance)
    updates = Update.updatesarr(instance)
      comments_array = Array.new
      updates.each do |ups|
        comments=ups.comments.find(:all)
        comments_array +=comments
      end
    comments_array
  end
    
 def self.export_comments(instance)
    comments_array =   commentsarr(instance)
    result_comments = comments_array.to_yaml
    result_comments.gsub!(/\n/,"\r\n")
    result_comments 
  end

end
