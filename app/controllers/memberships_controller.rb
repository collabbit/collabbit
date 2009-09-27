class MembershipsController < ApplicationController
  def create
    @instance = Instance.find(params[:instance_id])
    @user = @instance.users.find(params[:user_id])
    @group = @instance.groups.find(params[:group_id])
    
    return with_rejection unless @user.updatable?
    
    @user.groups << @group unless @user.groups.include?(@group)
    
    flash[:notice] = "You have joined this group."
    redirect_to instance_group_type_group_path(@instance, @group.group_type, @group)
  end
  def delete
    
  end
end
