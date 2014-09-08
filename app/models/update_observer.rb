class UpdateObserver < ActiveRecord::Observer
  
  @@enabled = true
  mattr_accessor :enabled
  def self.enable!
    @@enabled = true
  end
  def self.disable!
    @@enabled = false
  end  
    
  def after_create(update)
	
    find_and_send_alerts(update, 'new') if @@enabled
  end
  def after_update(update)
	
    find_and_send_alerts(update, 'updated') if @@enabled
  end
  
  private
    # Ensures only one update per person
    def find_and_send_alerts(update, action)
      alerts = {}
      update.incident.feeds.each do |f|
        if f.matches?(update)
          alerts[f.owner] = f
        end
      end
            
      alerts.each_pair do |user, feed|
        alerted = false
        if user.active? && user.text_alert && feed.text_alert && 
          !user.cell_phone.blank? && !user.carrier.blank? 
		  # Send later to delayed job
		  UserMailer.send_later :deliver_text_alert, user, feed, update, action
          alerted = true
        end
        if user.active? && user.email_alert? && feed.email_alert? 	
		  # Send later to delayed job			
		  UserMailer.send_later :deliver_email_alert, user, feed, update, action
          alerted = true
        end
        user.last_alerted = Time.now if alerted
        user.save
      end
      
    end  
   
end
