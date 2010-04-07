class SignupMailer < ActionMailer::Base
  
  helper :application
  
  def new_trial_notification(opts)
    @recipients = SETTINGS['host.support_email']
    @from = "NewTrial@#{SETTINGS['host.base_url']}"
    @subject = 'Collabbit: new trial requested'
    @sent_on = Time.now
    @body[:opts] = opts
  end

end
