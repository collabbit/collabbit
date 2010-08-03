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
      flash[:error] = t('error.user.invalid_email_or_password')
      render :action => :new
    end
  end

  def destroy
    logout_keeping_session!
    redirect_to login_path
  end

end

