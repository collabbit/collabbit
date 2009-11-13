# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class HomeController < ApplicationController
  
  skip_before_filter :require_login, :set_current_account

  def index
  end
  
  def show
    @return_to = params[:return_to] if params[:return_to]
    render :action => params[:page]
  end
  
end
