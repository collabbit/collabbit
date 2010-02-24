# Controller for operations on users in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class UsersController < AuthorizedController

  skip_before_filter :require_login, :only => [:new, :create, :forgot_password,
                                                    :reset_password, :activate]
  before_filter :logout_keeping_session!, :only => [:new, :create,
                                                    :forgot_password, :reset_password,
                                                    :activate]

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
    @user = User.new
    logout_keeping_session!
  end

  # Saves a user object to the database with the parameters provided in
  # the :user hash, which is populated by the form on the 'new' page
  def create
    @user = User.new(params[:user])
    @user.instance = @instance
    @user.state = User::STATES[:pending]

    @user.salt = Digest::SHA1.hexdigest(Time.now.to_s + @instance.short_name + rand.to_s)
    @user.crypted_password = @user.generate_crypted_password(@user.password)
    @user.activation_code = @user.generate_activation_code
    @user.role = @instance.roles.first #<<FIX: default role
    
    @instance.incidents.each do |i|
      @user.feeds << Feed.make_my_groupds_feed(i)
    end

    if @user.save
      flash[:notice] = t('notice.signup')
      redirect_to login_path
    else
      render :action => :new
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
    user = @instance.users.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    if (!params[:activation_code].blank?) && user && !user.active?
      if user.instance.whitelisted_domains.find_by_name(user.email.split('@').last)
        user.activate!
        flash[:notice] = t('notice.signup_complete')
      else
        user.enqueue_for_approval!
        flash[:notice] = t('notice.admin_approval_required')
      end
    elsif params[:activation_code].blank?
      flash[:error] = t('error.missing_activation_code')
    else
      flash[:error] = t('error.invalid_activation_code')
    end
    redirect_to new_session_path
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

  def forgot_password
  end

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
end

