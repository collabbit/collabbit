class MembershipsController < AuthorizedController
  def create
    user = @instance.users.find(params[:user_id])
    group = @instance.groups.find(params[:group_id])
    
    return with_rejection unless @current_user.can? :update => user
    
    if params[:leave]
      user.groups.delete group

      if @current_user.id == user.id 
        flash[:notice] = "You have left this group."
        redirect_to group_type_group_path(group.group_type, group)
      else 
        flash[:notice] = user.first_name + " " + user.last_name + " has left " + group.name + "."
        redirect_to user_path(user)
      end
    else
      user.groups << group unless user.groups.include?(group)
    
      if @current_user.id == user.id 
        flash[:notice] = "You have joined this group."
        redirect_to group_type_group_path(group.group_type, group)
      else 
        flash[:notice] = "#{user.full_name} has joined #{group.name}."
        redirect_to user_path(user)
      end
    end
  end
  
  def destroy
    membership = @current_user.memberships.find_by_id(params[:id])
    #return with_rejection unless @current_user.can? :destroy => membership
    
    membership.destroy
    flash[:notice] = t('notice.membership.destroyed', :group_name => membership.group.name)
    
    redirect_to(params[:redirect_to] || :back)
  end
end
