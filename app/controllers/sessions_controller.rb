# Controller for handling logging in for users.   
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class SessionsController < ApplicationController

  skip_before_filter :require_login

  def new
    @return_to = params[:return_to] || @instance
    redirect_to @instance if logged_in?
  end
  
  # Logs in a user specified by :email if the user is active and the password
  # is correct. 
  def create
    @user = @instance.users.find_by_email(params[:email])
    if @user and @user.state != User::STATES[:active]
      flash[:error] = INACTIVE_ACCOUNT
      render :action => :new
    elsif @user and @user.crypted_password == @user.generate_crypted_password(params[:password])
      if @user.last_logout
        flash[:notice] = "Hi #{@user.first_name}. Welcome back!"
      else
        flash[:notice] = "Hi #{@user.first_name}. Welcome to #{@instance.short_name}'s Collabbit. Need a brief tour? (Doesn't exist yet, so sorry, #{@user.first_name}.)"
      end
      login_as @user
      handle_remember_cookie!(true) if params[:remember]

      redirect_to params[:return_to] || @instance
    else
      flash[:error] = INVALID_EMAIL_OR_PASSWORD
      render :action => :new
    end
  end
  
  def destroy
    logout_keeping_session!
    redirect_to instance_login_path(Instance.find(params[:instance_id]))
  end

end
