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

  def create
    @user = @instance.users.find_by_email(params[:email])
    if @user and !@user.active?
      flash[:error] = t('error.user.pending')
      render :action => :new
    elsif @user and @user.crypted_password == @user.generate_crypted_password(params[:password])
      flash[:notice] = if @user.last_login
        t('notice.user.login', :name => @user.first_name)
      else
        t('notice.user.first_login', :name => @user.first_name, :instance => @instance.short_name)
      end
      
      login_as @user
      handle_remember_cookie!(true) if params[:remember_me]
      @user.last_login = DateTime.now
      @user.save

      redirect_to params[:return_to].blank? ? overview_path : params[:return_to]
      
    else
      flash[:error] = t('error.user.login_invalid')
      render :action => :new
    end
  end

  def destroy
    logout_keeping_session!
    redirect_to login_path
  end

end

