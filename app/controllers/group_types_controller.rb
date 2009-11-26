# Controller for operations on group_types in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class GroupTypesController < ApplicationController
    
  def new
    @group_type = GroupType.new
    return with_rejection unless GroupType.creatable_by?(@current_user)
  end

  def show
        
    @group_type = @instance.group_types.find(params[:id])
    redirect_to instance_group_type_groups_path(@instance, @group_type)
  end

  def edit
    
    @group_type = @instance.group_types.find(params[:id])
    return with_rejection unless @group_type.updatable_by?(@current_user)
  end

  def index
    
    @group_types = @instance.group_types
    return with_rejection unless GroupType.listable_by?(@current_user)
  end
  
  # Saves a group_type object to the database with the parameters provided in 
  # the :group_type hash, which is populated by the form on the 'new' page
  def create
    
    @group_type = GroupType.new(params[:group_type])
    
    return with_rejection unless GroupType.creatable_by?(@current_user)
    
    @group_type.instance = @instance

    if @group_type.save
      flash[:notice] = GROUP_TYPE_CREATED
      redirect_to instance_group_type_path(@instance, @group_type)
    else
      render :action => 'new'
    end
  end
  
  # Updates an existing group_type object in the database specified by its :id
  # The data to be saved is provided in the :group_type hash, 
  # which is populated by the form on the 'edit' page
  def update
    
    @group_type = @instance.group_types.find(params[:id])
    
    return with_rejection unless @group_type.updatable_by?(@current_user)
    
    if @group_type.update_attributes(params[:group_type])
      flash[:notice] = GROUP_TYPE_UPDATED
      redirect_to instance_group_type_path(@instance, @group_type)
    else
      render :action => 'edit'
    end
  end
  
  # Removes a group_types object specified by its :id from the database
  def destroy
    
    @group_type = @instance.group_types.find(params[:id])
    return with_rejection unless @group_type.destroyable_by?(@current_user)
    @group_type.destroy
    redirect_to :action => :index
  end

end
