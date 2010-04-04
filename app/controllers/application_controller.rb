# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class ApplicationController < ActionController::Base
  require 'digest/sha1'
  helper :all # include all helpers, all the time
  
  filter_parameter_logging 'password'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd9a4fa2487b71adf1f4fb8d68c2fcc59'
  
  rescue_from Instance::Missing do |instance|
    flash[:error] = "We're sorry, we couldn't find a Collabbit for <strong>#{instance}</strong>."
    render "shared/404", :layout => 'home'
  end
  
  # rescue_from ActiveRecord::RecordNotFound do
  #     flash[:error] = "We're sorry, something you just requested was misplaced."
  #     redirect_to @instance
  #   end
  
  layout :check_if_promo_layout
  
  
  after_filter :set_admin_flash
  before_filter :set_current_account
  before_filter :check_account_redirect
  
  helper_method :promo?, :subdomain
  
  def set_current_account
    @instance = Instance.find_by_short_name(subdomain)    
    raise Instance::Missing, subdomain if @instance.blank? && !subdomain_forbidden?
  end
  
  def subdomain_forbidden?
    Instance::FORBIDDEN_SUBDOMAINS.include?(subdomain) || subdomain.blank?
  end
  
  def check_account_redirect
    redirect_to login_path unless promo? || controller_name != 'home'
    redirect_to about_path if promo? && params[:page].blank?
  end
  
  def check_if_promo_layout
    promo? ? 'home' : 'application'
  end
  
  def promo?
    return true if Instance::FORBIDDEN_SUBDOMAINS.include? subdomain || subdomain.blank?
    return true unless Instance.exists?(:short_name => subdomain)
    return controller_name == 'home' && !params[:page].blank?
  end
  
  def subdomain
    request.subdomains.first || ''
  end
  
  def notice=(*args)
    flash[:notice] = t(*args)
  end
  def error=(*args)
    flash[:error] = t(*args)
  end
  
  def set_admin_flash
    if !promo? && logged_in? && @current_user.permission_to?(:update, User) && User.exists?(:state => 'pending') && flash[:notice].blank?
      flash[:notice] = t('notice.user.pending_users', :url => users_path(:states_filter => 'pending'))
    end
  end
  
end