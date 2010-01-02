# Controller for handling logging in for users.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class SessionsController < AuthorizedController

  skip_before_filter :require_login

  def new
    @return_to = params[:return_to] || overview_path
    redirect_to overview_path if logged_in?
  end

  # Logs in a user specified by :email if the user is active and the password
  # is correct.
  def create
    @user = @instance.users.find_by_email(params[:email])
    if @user and @user.state != 'active'
      flash[:error] = case @user.state
      when 'pending' then t('error.inactive_account')
      when 'pending_approval' then t('error.pending_approval')
      end
      render :action => :new
    elsif @user and @user.crypted_password == @user.generate_crypted_password(params[:password])
      if @user.last_logout
        flash[:notice] = "Hi #{@user.first_name}. Welcome back!"
      else
        flash[:notice] = "Hi #{@user.first_name}. Welcome to #{@instance.short_name}'s Collabbit."
      end
      login_as @user
      handle_remember_cookie!(true) if params[:remember]
      @user.last_login = DateTime.now
      @user.save

      if params[:return_to] == nil || params[:return_to].size == 0
        redirect_to overview_path
      else
        redirect_to params[:return_to]
      end
    else
      flash[:error] = t('error.invalid_email_or_password')
      render :action => :new
    end
  end

  def destroy
    logout_keeping_session!
    redirect_to login_path
  end

end

