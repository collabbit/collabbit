# Controller for operations on groups in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class GroupsController < AuthorizedController
    
  def new
    @instance = Instance.find(params[:instance_id])
    @group = Group.new
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless Group.creatable_by?(@current_user)
  end

  def show
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.viewable_by?(@current_user)
  end

  def edit
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.updatable_by?(@current_user)
  end

  def index
    @instance = Instance.find(params[:instance_id])
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless Group.listable_by?(@current_user)
  end

  # Saves a group object to the database with the parameters provided in 
  # the :group hash, which is populated by the form on the 'new' page
  def create
    flash = {}
    return with_rejection unless Group.creatable_by?(@current_user)
    
    @instance = Instance.find(params[:instance_id])
    @group_type = @instance.group_types.find(params[:group_type_id])
    @group = @group_type.groups.build(params[:group])
        
    if @group.save
      flash[:notice] = GROUP_CREATED
      redirect_to instance_group_type_group_path(@instance, @group_type, @group)
    else
      flash[:error] = GROUP_CREATE_ERROR
      render :action => 'new'
    end
  end
  
  # Updates an existing group object in the database specified by its :id.
  # The data to be saved is provided in the :group hash, 
  # which is populated by the form on the 'edit' page.
  def update
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.updatable_by?(@current_user)

    if @group.update_attributes(params[:group])
      flash[:notice] = GROUP_UPDATED
      redirect_to instance_group_type_group_path(@instance, @group.group_type, @group)
    else
      flash[:error] = GROUP_UPDATE_ERROR
      render :action => 'new'
    end
  end
  
  # Removes a group object specified by its :id from the database
  def destroy
    @group = @instance.groups.find(params[:id])
    gt = @group.group_type
    return with_rejection unless @group.destroyable_by?(@current_user)
    @group.destroy
    redirect_to [@instance, gt]
  end

end
