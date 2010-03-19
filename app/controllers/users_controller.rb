# Controller for operations on users in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class UsersController < AuthorizedController

  skip_before_filter :require_login, :only => [:new, :create, :forgot_password,
                                               :reset_password, :activate, :edit_password,
                                               :update_password, :activation_update]

  def index
    return with_rejection unless @current_user.can?(:list => @instance.users)
    
    pagination_options = {
      :page => params[:page],
      :per_page => 100,
      :include => :groups,
      :order => 'last_name ASC'
    }
    
    search_options = {}
    
    unless params[:groups_filter].blank?
      search_options[:groups_id_is] = @groups_filter = params[:groups_filter]
    end
    
    if params[:states_filter].blank? || !@current_user.can?(:update => @instance.users)
      search_options[:state_equals] = 'active'
      @states_filter = 'active' if @current_user.can?(:update => @instance.users)
    else
      search_options[:state_equals] = @states_filter = params[:states_filter]
    end
    
    unless params[:search].blank?
      @search = params[:search]    
      if params[:search] =~ /\A([a-zA-Z\-]+), ([a-zA-Z\-]+)\z/
        search_options[:first_name_starts_with] = $2
        search_options[:last_name_starts_with] = $1
      elsif params[:search] =~ /\A([a-zA-Z\-]+) ([a-zA-Z\-]+)\z/
        search_options[:first_name_starts_with] = $1
        search_options[:last_name_starts_with] = $2
      else
        search_options[:first_name_or_last_name_or_cell_phone_or_desk_phone_or_email_like] = @search
      end
    end
    
    @users = @instance.users.search(search_options).paginate(pagination_options)
  end

  def show
    @user = @instance.users.find(params[:id])
    return with_rejection unless @current_user.can? :view => @user

    respond_to do |f|
      f.html { render :action => :show }
      f.vcf do
        send_data @user.to_vcard.to_s, {
          :type => 'vcf',
          :filename => "#{@user.full_name.gsub(' ', '-')}.vcf"
        }
      end
    end
  end

  def edit
    @user = @instance.users.find(params[:id])
    return with_rejection unless @current_user.can? :update => @user
  end

  def new
    return with_rejection unless !logged_in? || @current_user.can?(:create => User)
    @user = User.new
  end
  
  def new_bulk
    return with_rejection unless !logged_in? || @current_user.can?(:create => User)
  end

  # Saves a user object to the database with the parameters provided in
  # the :user hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless !logged_in? || @current_user.can?(:create => User)
    
    @user = create_user(params[:user])
    @user.state = 'approved' if logged_in?

    if @user.save
      if logged_in?
        flash[:notice] = t('notice.user.created', :name => @user.first_name)
        redirect_to user_path(@user)
      else
        flash[:notice] = t('notice.user.signup')
        redirect_to login_path #<<FIX: make a new path
      end
    elsif logged_in?
      flash[:notice] = t('error.user.creation_failed')
      render :new
    else
      flash[:notice] = t('error.user.signup_failed')
      render :new
    end
  end
  
  def create_bulk
    return with_rejection unless @current_user.can? :create => User
    errors = false
    CSV::Reader.parse(params[:csv_file]).each do |u|
      begin
        user = create_user({:first_name => u.shift.strip,
                            :last_name => u.shift.strip,
                            :email => u.shift.strip,
                            :state => 'approved' })
        user.save
      rescue
       errors = true
      end
    end
    
    if errors
      flash[:error] = t('error.bulk_import.failed')
      render new_bulk_users_path
    else
      flash[:notice] = t('notice.bulk_import.success')
      redirect_to users_path
    end
  end

  # Updates an existing user object in the database specified by its :id.
  # The data to be saved is provided in the :user hash,
  # which is populated by the form on the 'edit' page.
  def update
    @user = @instance.users.find(params[:id])
    return with_rejection unless @current_user.can? :update => @user

    if @current_user.permission_to?(:update, @user) && params[:user][:state] != nil
      @user.state = params[:user][:state]
      params[:user].delete(:state)
    end
    
    if @user.update_attributes(params[:user])
      flash[:notice] = t('notice.user_updated')
      redirect_to params[:return_to] || @user
    else
      render :action => 'new'
    end
  end

  # Activates an existing user, identified by the :activation_code provided
  # If the activation code is wrong or missing, the user is not activated
  def activate
    @code = params[:activation_code]
    @user = @instance.users.find_by_activation_code(@code) unless @code.blank?
    
    if @code.blank? || @user == nil || @user.active?
      flash[:error] = t('error.user.invalid_activation_code')
      redirect_to new_session_path
    elsif @user.whitelisted? || @user.approved?
      flash[:notice] = t('notice.user.need_account_setup')
    else
      flash[:error] = t('error.user.invalid_activation_code')
      redirect_to new_session_path
    end
  end
  
  def activation_update
    @user = @instance.users.find(params[:id])
    if @user.activation_code == params[:activation_code]
      if params[:user][:password].blank?
        flash[:error] = t('error.user.password_required')
        redirect_to :back
      elsif @user.update_attributes(params[:user])
        @user.activate!
        flash[:notice] = t('notice.user.initial_updated')
        redirect_to new_session_path
      else
        flash[:error] = t('error.user.invalid_data')
        redirect_to :back
      end
    else
      flash[:error] = t('error.user.unauthorized_editing')
      redirect_to new_session_path
    end
  end

  # Removes a user object from the database
  def destroy
    @user = @instance.users.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @user
    @user.destroy
    redirect_to users_path
  end

  def vcards
    @users = @instance.users.find(params[:users].split(','))
    return with_rejection unless @current_user.can? :list => @users
    respond_to do |f|
      f.vcf do
        send_data( (@users.map {|u| u.to_vcard.to_s}).join, {
          :type => 'vcf',
          :filename => "#{@instance.short_name}-contacts.vcf"})
      end
    end
  end

  def forgot_password; end

  def reset_password
    @user = @instance.users.find_by_email(params[:user][:email])
    unless @user == nil
      pass = @user.generate_activation_code[0,12]
      @user.password = @user.password_confirmation = pass
      @user.save
      UserMailer.deliver_password_reset(@user, pass)
    end
    flash[:notice] = t( 'notice.password_reset')
    redirect_to new_session_path
  end
  
  private
    def create_user(params)
      user = @instance.users.build(params)
      
      user.state = if params[:state] && logged_in? && @current_user.can?(:update => User)
        params[:state]
      else
        'pending'
      end

      user.generate_salt!
      user.generate_crypted_password!
      user.generate_activation_code!
      user.role = @instance.roles.first #<<FIX: default role

      @instance.incidents.each do |i|
        user.feeds << Feed.make_my_groups_feed(i)
      end
      
      user
    end
end

