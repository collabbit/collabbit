# Controller for operations on instances in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class InstancesController < AuthorizedController
  def index
    @instances = Instance.all
    return with_rejection unless @current_user.can? :list => @instances
  end

  def show
    @incidents = @instance.incidents.find(:all,:include => [:updates], :order => 'id DESC')
    return with_rejection unless @current_user.can? :list => @incidents, :view => @instance
  end

  # Method for displaying the information needed on the 'Edit instance' page,
  # which lets the user edit the name of the instance and the permissions
  # associated with each role.
  # It passes the permissions to the view in a hash in which the
  # permissions are organized by their model.
  def edit
    return with_rejection unless @current_user.can? :update => @instance
    @perms_hash = Permission.all.inject({}) do |res, e|
      res[e.model] = [] unless res.include? e.model
      res[e.model] << e.action
      res
    end
    @roles = Role.all
  end

  # Updates an existing instance object in the database specified by its :id
  # The data to be saved is provided in the :instance hash,
  # which is populated by the form on the 'edit' page
  # It also saves the updated permissions to the database based
  # on the :permissions hash
  def update
    return with_rejection unless @current_user.can? :update => @instance
    if params[:permissions].is_a? Hash
      @instance.roles.each do |r|
        r.privileges.clear #<<FIX: make this not destroy already right ones
        r.save
      end
      params[:permissions].each_pair do |role_id, rest|
        role = @instance.roles.find(role_id)
        rest.each_pair do |model_name, actions|
          actions.each do |action_name|
            permission = Permission.find(:first, :conditions => {:model => model_name, :action => action_name})
            Privilege.create(:role => role, :permission => permission)
          end
        end
      end
    end
    if @instance.update_attributes(params[:instance])
      flash[:notice] = t('notice.instance_updated')
      redirect_to overview_path
    else
      render :action => 'edit'
    end
  end

  # Removes an instance object specified by its :id from the database
  def destroy
    return with_rejection unless @current_user.can? :destroy => @instance
    @instance.destroy
    redirect_to @instance
  end

  def new
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.new
  end

  # Saves an instance object to the database with the parameters provided in
  # the :instance hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.build(params[:instance])
    if @instance.save
      flash[:notice] = t('notice.instance_created')
      redirect_to @instance
    else
      render :action => 'new'
    end
  end

end

