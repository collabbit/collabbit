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
