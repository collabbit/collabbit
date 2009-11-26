# Controller for handling managing roles.   
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class RolesController < ApplicationController

  def show
    @instance = Instance.find(params[:instance_id])
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @role.viewable_by?(@current_user) and @instance.viewable_by?(@current_user)
  end

  def edit
    @instance = Instance.find(params[:instance_id])
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @role.updatable_by?(@current_user) and @role.viewable_by?(@current_user) and @instance.viewable_by?(@current_user)
  end

  def index
    @instance = Instance.find(params[:instance_id])
    @roles = @instance.roles
    return with_rejection unless Role.listable_by?(@current_user) and @instance.viewable_by?(@current_user)
  end
  
  # Updates an existing role in the database based on the parameters
  # provided in the view, which are stored in the :role hash. 
  def update
    @instance = Instance.find(params[:instance_id])
    @role = @instance.roles.find(params[:id])
    return with_rejection unless @role.updatable_by?(@current_user) and @instance.viewable_by?(@current_user)
    if @role.update_attributes(params[:role])
      flash[:notice] = ROLE_UPDATED
      redirect_to instance_role_path(@instance, @role)
    else
      render :action => 'new'
    end
  end

end
