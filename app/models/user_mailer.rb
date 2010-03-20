# Prepares welcome and activation messages to newly-registered users
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class UserMailer < ActionMailer::Base
  
  helper :application
  
  # Prepares an activation link to a newly-registered user
  def approved_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{user.instance.short_name}.collabbit.org/activate/#{user.activation_code}"
  end
  
  # Someone else set up an account
  def new_account_notification(user)
    setup_email(user)
    @subject += 'invitation to join'
    @body[:url] = "http://#{user.instance.short_name}.collabbit.org/activate/#{user.activation_code}"
    @body[:superadmin] = user.instance.roles.last.users.first
  end
  
  def pending_account_notification(user)
    setup_email(user)
    @subject += 'account pending'
  end
  
  # Prepares an account activation confirmation to a user 
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{user.instance.short_name}.collabbit.org/"
  end
  
  def password_reset(user, password)
    setup_email(user)
    @subject += "password reset notice"
    @body[:url] = "http://#{user.instance.short_name}.collabbit.org/"
    @body[:pass] = password
  end
  
  def text_alert(user, feed, update, action)
    setup_email(user)
    @recipients = user.text_email
    @subject = ''
    @body = {:user => user, :feed => feed, :update => update, :action => action}
  end
  def email_alert(user, feed, update, action)
    setup_email(user)
    @subject = "Collabbit: #{user.instance.long_name}"
    @body = {:user => user, :feed => feed, :update => update, :action => action}
  end
  
  protected
    # Sets up some email variables
    def setup_email(user)
      @recipients  = user.email
      @from        = "Collabbit#{user.instance.short_name}@collabbit.org"
      @subject     = "Collabbit: "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
