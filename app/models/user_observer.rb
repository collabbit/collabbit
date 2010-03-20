# Listens for user creation and then handles email authentication
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
class UserObserver < ActiveRecord::Observer
  
  @@enabled = true
  mattr_accessor :enabled
  
  def after_create(user)
    if user.approved? && @@enabled
      UserMailer.deliver_new_account_notification(user)
    elsif user.pending? && @@enabled
      UserMailer.deliver_pending_account_notification(user)
    end
  end
  
  # Sends an activation email after a user's account is registered
  def before_update(user)
    if user.approved? && !user.new_record? && !User.find(user.id).approved? && @@enabled
      UserMailer.deliver_approved_notification(user)
    end
  end
  
  def self.enable!
    @@enabled = true
  end
  def self.disable!
    @@enabled = false
  end
  
end
