class SignupMailer < ActionMailer::Base
  helper :application
  
  def new_trial_notification(opts)
    @recipients = SETTINGS['host.support_email']
    @from = "NewTrial@#{SETTINGS['host.base_url']}"
    @subject = 'Collabbit: new trial requested'
    @sent_on = Time.now
    @body[:opts] = opts
  end

  def contact_form_notification(subject,body)
    @recipients = SETTINGS['host.support_email']
    @from = "ContactForm@#{SETTINGS['host.base_url']}"
    @subject = "Collabbit Contact Form: #{subject}"
    @sent_on = Time.now
    @body = body
  end
end
