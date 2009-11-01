# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class ApplicationController < ActionController::Base
  include Auth
  require 'digest/sha1'
  helper :all # include all helpers, all the time
  
  before_filter :login, :require_login
  before_filter :set_current_account # thank you 37signals

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd9a4fa2487b71adf1f4fb8d68c2fcc59'
  
  private
    def set_current_account
      @instance = Instance.find_by_short_name(request.subdomains.first)
      @instance ||= Instance.find_by_short_name(params[:instance_id]) || Instance.find_by_short_name(params[:id])
      Instance.current = @instance
    end
end
