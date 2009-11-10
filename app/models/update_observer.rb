# Listens for user creation and then handles email authentication
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class UpdateObserver < ActiveRecord::Observer
  
  @@enabled = true
  mattr_accessor :enabled
  
  def after_create(update)
    find_and_send_alerts(update, 'created')
  end
  def after_update(update)
    find_and_send_alerts(update, 'updated')
  end
  
  def self.enable!
    @@enabled = true
  end
  def self.disable!
    @@enabled = false
  end
  
  private
    # Ensures only one update per person
    def find_and_send_alerts(update, action)
      alerts = {}
      update.incident.feeds.each do |f|
        if f.alert? && f.matches?(update)
          alerts[f.owner] = f
        end
      end
      
      puts 'Alerts'
      alerts.each_pair do |user, feed|
        UserMailer.deliver_text_alert(user, feed, update, action)
        puts "#{user.full_name} ==> #{update.title}"
      end
      
    end    
end
