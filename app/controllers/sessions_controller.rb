class SessionsController < AuthorizedController

  skip_before_filter :require_login

  def new
    @return_to = params[:return_to] || overview_path
    redirect_to overview_path if logged_in?
    if @instance.short_name == 'demo' && !logged_in?
      flash[:notice] = "Demo username/password: demo@collabbit.org/demo."
    end
  end

  def create
    @user = @instance.users.find_by_email(params[:email])
    if @user and !@user.active?
      flash[:error] = t('error.user.pending')
      render :action => :new
    elsif @user and @user.password_matches?(params[:password])
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

