# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class HomeController < ApplicationController
  
  def show
    @return_to = params[:return_to] if params[:return_to]
    if methods.include? params[:page]  
      send params[:page].to_sym
    else
      render :action => params[:page]
    end
  end
  
  def new_trial
    SignupMailer.deliver_new_trial_notification(params)
    
    flash[:notice] = t('notice.instance.trial_requested',
                          :email => params[:email],
                          :support => "<a href=\"mailto:#{SETTINGS['host.support_email']}\">support</a>")
                          
    redirect_to '/about'
  end
  
  
end
