# Controller for operations on users in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class UsersController < ApplicationController

  skip_before_filter :require_login, :only => [:new, :create, :forgot_password,
                                                    :reset_password, :activate]
  before_filter :logout_keeping_session!, :only => [:new, :create,
                                                    :forgot_password, :reset_password,
                                                    :activate]

  def index
    return with_rejection unless User.listable? and @instance.viewable?
    @users = @instance.users.paginate :all,
                                      :page         => params[:page],
                                      :per_page     => 100,
                                      :conditions   => search,
                                      :include      => [:groups],
                                      :filters      => filters,
                                      :order        => 'last_name ASC',
                                      :filter_style => :and
    @group_filter = params[:filters] && 
                    !params[:filters][:groups].blank? &&
                    !params[:filters][:groups][:id].blank? &&
                    @instance.groups.find(params[:filters][:groups][:id])
    #if User.updatable?
    #  @pending_filter = (params[:filters] && params[:filters]['state']) || 'active'
    #end
    @search = params[:search] if params[:search] and params[:search].length > 0 
  end

  def show 
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.viewable? and @instance.viewable?
    
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
    return with_rejection unless @user.updatable? and @instance.viewable?
  end

  def new
    @user = User.new
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
    @user.role = @instance.roles.first

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
    user = @instance.users.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    if (!params[:activation_code].blank?) && user && !user.active?
      if user.instance.whitelisted_domains.include?(user)
        user.activate!
        flash[:notice] = SIGNUP_COMPLETE
      else
        user.enqueue_for_approval!
        flash[:notice] = ADMIN_APPROVAL_REQUIRED
      end
    elsif params[:activation_code].blank?
      flash[:error] = MISSING_ACTIVATION_CODE
    else 
      flash[:error]  = INVALID_ACTIVATION_CODE
    end
    redirect_to new_instance_session_path(@instance)
  end

  # Removes a user object from the database
  def destroy    
    @user = @instance.users.find(params[:id])
    return with_rejection unless @user.destroyable?
    @user.destroy
    redirect_to instance_users_path(@instance)
  end
  
  def vcards
    @users = @instance.users.find(params[:users].split(','))
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
      @user.password = pass
      @user.save
      UserMailer.deliver_password_reset(@user, pass)
    end
    flash[:notice] = PASSWORD_RESET
    redirect_to new_instance_session_path(@instance)
  end
  
  private
    # Returns an array of conditions for filtering contacts based on GET params
    def search
      return unless params[:search] && !params[:search].blank?
      values = {}
      fields = [:first_name, :last_name, :email, :cell_phone, :desk_phone]
      query = (fields.map{|f| "#{f} LIKE :#{f}"}).join(" OR ")
      fields.each do |field|
        values[field] = "#{params[:search]}%" 
      end
      
      #check for last, first
      if params[:search] =~ /\A([a-zA-Z\-]+), ([a-zA-Z\-]+)\z/
        query += " OR (`last_name` = :slast_name AND `first_name` = :sfirst_name)"
        values[:slast_name] = $1
        values[:sfirst_name] = $2
      elsif params[:search] =~ /\A([a-zA-Z\-]+) ([a-zA-Z\-]+)\z/
        query += " OR (`last_name` = :slast_name AND `first_name` = :sfirst_name)"
        values[:slast_name] = $2
        values[:sfirst_name] = $1
      end
      
      [query, values]
    end
  
    def filters
      if params[:filters] && params[:filters][:state] && !User.updatable?
        params[:filters].delete(:state)
      end      
      {'state' => 'active'}.merge(params[:filters] || {})
    end
end
