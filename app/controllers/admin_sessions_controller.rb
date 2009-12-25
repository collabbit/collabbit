# Controller for handling logging in for users.   
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class AdminSessionsController < AuthorizedController

  skip_before_filter :require_login
  layout 'home'

  def new
    redirect_to admins_path if logged_in?(:admin)
  end
  
  # Logs in a user specified by :email if the user is active and the password
  # is correct. 
  def create
    @admin = Admin.find_by_email(params[:email])
    if @admin && @admin.crypted_password == @admin.generate_crypted_password(params[:password])
      login_as @admin, :admin
      redirect_to admins_path
    else
      flash[:error] = INVALID_EMAIL_OR_PASSWORD
      render :action => :new
    end
  end
  
  def destroy
    logout_keeping_session!
    redirect_to login_path
  end

end
