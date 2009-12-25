class MembershipsController < AuthorizedController
  def create
    user = @instance.users.find(params[:user_id])
    group = @instance.groups.find(params[:group_id])
    
    return with_rejection unless @current_user.can? :update => user
    
    if params[:leave]
      user.groups.delete group

      flash[:notice] = "You have left this group."
      redirect_to instance_group_type_group_path(@instance, group.group_type, group)
    else
      user.groups << group unless user.groups.include?(group)
    
      flash[:notice] = "You have joined this group."
      redirect_to instance_group_type_group_path(@instance, group.group_type, group)
    end
  end
end
