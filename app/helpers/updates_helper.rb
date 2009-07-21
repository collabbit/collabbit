module UpdatesHelper

  def issuer_link(u)
    if u.issuing_type == :user
      link_to u.user.full_name, instance_user_url(@instance, u.user)
    else
      link_to u.issuing_group.name, instance_group_type_group_url(@instance, u.issuing_group.group_type, u.issuing_group)
    end
  end

end
