# Controller for operations on instances in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class InstancesController < ApplicationController    
  def index
    @instances = Instance.all
    return with_rejection unless @instances.listable? && Instance.listable?
  end
  
  def show
    @incidents = @instance.incidents.find(:all,:include => [:updates], :order => 'id DESC')
    return with_rejection unless @instance.viewable?
  end

  # Method for displaying the information needed on the 'Edit instance' page,
  # which lets the user edit the name of the instance and the permissions 
  # associated with each role. 
  # It passes the permissions to the view in a hash, called perms_hash, in which the
  # pemissions are organized by their model. 
  def edit
    @roles = @instance.roles
    @permissions = Permission.all
    @perms_hash = {}
    @permissions.each do |p|
      @perms_hash[p.model] = [] unless @perms_hash[p.model].is_a?(Array)
      @perms_hash[p.model] << p.action
    end
    return with_rejection unless @instance.updatable?
  end

  # Updates an existing instance object in the database specified by its :id
  # The data to be saved is provided in the :instance hash, 
  # which is populated by the form on the 'edit' page
  # It also saves the updated permissions to the database based 
  # on the :permissions hash
  def update
    return with_rejection unless @instance.updatable?
    if params[:permissions].is_a? Hash
      @instance.roles.each do|r|
        r.privileges.clear
        r.save
      end
      params[:permissions].each_pair do |role_id, rest|
        role = @instance.roles.find(role_id)
        rest.each_pair do |model_name, actions|
          actions.each do |action_name|
            permission = Permission.find(:first, :conditions => {:model => model_name, :action => action_name})
            p = Privilege.create(:role => role, :permission => permission)
          end
        end
      end
    end
    if @instance.update_attributes(params[:instance])
      flash[:notice] = INSTANCE_UPDATED
      redirect_to @instance
    else
      render :action => 'edit'
    end
  end

  # Removes an instance object specified by its :id from the database
  def destroy
    return with_rejection unless @instance.destroyable?
    @instance.destroy
    redirect_to instances_path
  end

  def new
    @instance = Instance.new
    return with_rejection unless @instance.creatable?
  end

  # Saves an instance object to the database with the parameters provided in 
  # the :instance hash, which is populated by the form on the 'new' page
  def create
    @instance = Instance.create(params[:instance])
    return with_rejection unless @instance.creatable?
    if @instance.valid?
      flash[:notice] = INSTANCE_CREATED
      redirect_to @instance
    else
      render :action => 'new'
    end
  end
  
end
