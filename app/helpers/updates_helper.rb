module UpdatesHelper

  def issuer_link(u)
    if u.issuing_type == :user
      if u.user == nil
        user = User::Archive.find(u.user_id)
        "#{user.first_name} #{user.last_name}"
      else
        link_to u.user.full_name, u.user 
      end
    elsif u.issuing_group != nil
      link_to u.issuing_group.name, group_type_group_url(u.issuing_group.group_type, u.issuing_group)
    else
      # group was deleted!
    end
  end
  
  # trims at the last word ending at or before 'len'
  def truncate_at(str,len)
    truncated = str[0..len+1]
    if truncated[-1] =~ /\s/
      truncated.strip!
    else
      words = truncated.split(' ')
      words.delete_at(-1)
      truncated = words.join(' ')
    end
    truncated
  end
end
