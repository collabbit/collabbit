# Controller for operations on users in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class UsersController < ApplicationController

  skip_before_filter :require_login, :only => [:new, :create]

  def index
    @instance = Instance.find(params[:instance_id])
    return with_rejection unless User.listable? and @instance.viewable?
    @users = @instance.users.paginate :all,
                                      :page         => params[:page],
                                      :per_page     => 100,
                                      :conditions   => search,
                                      :filters      => filters
      
    @users.sort! {|a,b| a.last_name <=> b.last_name}
    
    @group_filter = params[:filters] && 
                    !params[:filters][:groups].blank? &&
                    !params[:filters][:groups][:id].blank? &&
                    @instance.groups.find(params[:filters][:groups][:id])
    @search = params[:search] if params[:search] and params[:search].length > 0 
  end

  def show
    @instance = Instance.find(params[:instance_id])
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.viewable? and @instance.viewable?
  end
  
  def edit
    @instance = Instance.find(params[:instance_id])
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.updatable? and @instance.viewable?
  end

  def new
    @instance = Instance.find(params[:instance_id])
    @user = User.new
  end
 
  # Saves a user object to the database with the parameters provided in 
  # the :user hash, which is populated by the form on the 'new' page
  def create
    @instance = Instance.find(params[:instance_id])
    
    @user = User.new(params[:user])
    @user.instance = @instance
    @user.state = User::STATES[:pending]

    @user.salt = Digest::SHA1.hexdigest(Time.now.to_s + @instance.short_name + rand.to_s)
    @user.crypted_password = @user.generate_crypted_password(@user.password)
    @user.activation_code = @user.generate_activation_code
    @user.role = Role.default

    if @user.save
      # Note: activation email isn't sent yet
      flash[:notice] = SIGNUP_NOTICE
      redirect_to instance_login_path(@instance)
    else
      render :action => :new
    end
  end
  
  # Updates an existing user object in the database specified by its :id.
  # The data to be saved is provided in the :user hash, 
  # which is populated by the form on the 'edit' page.
  def update
    @instance = Instance.find(params[:instance_id])
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.updatable?

    if @user.update_attributes(params[:user])
      flash[:notice] = USER_UPDATED
      redirect_to instance_user_path(@instance, @user)
    else
      render :action => 'new'
    end
  end

  # Activates an existing user, identified by the :activation_code provided  
  # If the activation code is wrong or missing, the user is not activated
  def activate
    @instance = Instance.find(params[:instance_id])
    user = @instance.users.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    if (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = SIGNUP_COMPLETE
    elsif params[:activation_code].blank?
      flash[:error] = MISSING_ACTIVATION_CODE
    else 
      flash[:error]  = INVALID_ACTIVATION_CODE
    end
    redirect_to new_instance_session_path(@user)
  end

  # Removes a user object from the database
  def destroy
    @instance = Instance.find(params[:instance_id])
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.destroyable?
    @user.destroy
    redirect_to users_path
  end
  
  private
    # Returns an array of conditions for filtering contacts based on GET params
    def search
      return unless params[:search] and !params[:search].blank?
      values = {}
      fields = [:first_name, :last_name, :email, :cell_phone, :desk_phone]
      query = (fields.map{|f| "#{f} LIKE :#{f}"}).join(" OR ")
      fields.each do |field|
        values[field] = "%#{params[:search]}%" 
      end      
      [query, values]
    end
  
    def filters
      params[:filters]
    end
end
