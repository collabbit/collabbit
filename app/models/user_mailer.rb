# Prepares welcome and activation messages to newly-registered users
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class UserMailer < ActionMailer::Base
  
  # Prepares an activation link to a newly-registered user
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://localhost:3000/instances/#{user.instance.short_name}/activate/#{user.activation_code}"
    
  end
  
  # Prepares an account activation confirmation to a user 
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://collabbit.com/instances/#{user.instance.short_name}"
  end
  
  def test
    @recipients = "efoxepstein@wesleyan.edu"
    @from = "noreply@localhost"
    @subject = "Test"
    @sent_on = Time.now
  end
  
  protected
    # Sets up some email variables
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@elilies.com"
      @subject     = "Collabbit: "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
