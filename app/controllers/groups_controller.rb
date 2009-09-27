# Controller for operations on groups in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class GroupsController < ApplicationController
    
  def new
    @instance = Instance.find(params[:instance_id])
    @group = Group.new
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless Group.creatable?
  end

  def show
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.viewable?
  end

  def edit
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.updatable?
  end

  def index
    @instance = Instance.find(params[:instance_id])
    @group_type = @instance.group_types.find(params[:group_type_id])
    return with_rejection unless Group.listable?
  end

  # Saves a group object to the database with the parameters provided in 
  # the :group hash, which is populated by the form on the 'new' page
  def create
    flash = {}
    return with_rejection unless Group.creatable?
    
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
    return with_rejection unless @group.updatable?

    if @group.update_attributes(params[:group])
      flash[:notice] = GROUP_UPDATED
      redirect_to instance_group_type_group_path(@instance, @group.group_type, @group)
    else
      render :action => 'new'
    end
  end
  
  # Removes a group object specified by its :id from the database
  def destroy
    @instance = Instance.find(params[:instance_id])
    @group = @instance.groups.find(params[:id])
    return with_rejection unless @group.destroyable?
    @group.destroy
    redirect_to incidents_path
  end

end
