# Listens for user creation and then handles email authentication
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class UpdateObserver < ActiveRecord::Observer
    
  def after_create(update)
    find_and_send_alerts(update, 'created')
  end
  def after_update(update)
    find_and_send_alerts(update, 'updated')
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
        if !user.cell_phone.blank? && !user.carrier.blank? && feed.text_alert?
          UserMailer.deliver_text_alert(user, feed, update, action)
        end
        UserMailer.deliver_email_alert(user, feed, update, action) if feed.email_alert?
        user.last_alerted = Time.now
        user.save
      end
      
    end    
end
