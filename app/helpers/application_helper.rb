# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def can?(hsh)
    @current_user.can? hsh
  end
  
  def active(cond)
    ' class="active" ' if cond
  end
  
  def flashes
    f = ''
    for k in [:error, :warning, :notice, :message]
      f += content_tag(:div, content_tag(:div, flash[k]), :id => k) if flash[k]
    end
    (f.length > 0 && content_tag(:div, f, :id => 'flashes')) || ''
  end
  
  def menu_item(text, path, a = false)
    "<li #{active(a)}>" + link_to(text, path) + "</li>"
  end
 
  def li_link_to(text,path,li_attrs={})
    "<li"+li_attrs.collect {|k,v| " #{k}=\"#{v}\""}.join + ">"+link_to(text,path)+"</li>"
  end

  def incidents_menu(a = false)
    incidents = @instance.incidents.find(:all, :order => 'created_at DESC', :limit => 3, :conditions => {:closed_at => nil})
    links = incidents.collect do |incident|
      name = incident.name + (incident == @incident ? ' &laquo;' : '')
      classes = 'other' + (incident == @incident ? ' current_incident' : '')
      li_link_to(name,incident,{'class'=>classes})
    end
    "<li id=\"incidents-li\" #{active(a)}>" +  
      link_to('Incidents &#9662;',incidents_path,{'class' => 'visible'}) +
      "<ul id=\"incidents-menu\">\n" +  
      links.join("\n") +
    "\n</ul></li>"
  end

  def breadcrumbs(*args)
    ([[@instance.long_name,overview_path]]+args).collect { |n,l| link_to(n,l) }.join(' &#9656; ')
  end

  def subheader_text(text)
    '<p id="subheader_text">' + text + '</p>'
  end

  def title(*args)
    default = @instance ? [@instance.long_name,'Collabbit'] : ['Collabbit']
    args.flatten.concat(default).join(' &laquo; ')
  end
  
  #month day, year
  def mdy(x)
    x.strftime('%b %d, %Y')
  end

  # displays year only if it's not the current one
  # displays 'today' instead of month/day if date is today
  def mdy_smart(x)
    x = x - 560.seconds # TEMPORARY: REMOVE
    if x.year == Time.now.year
      if x.month == Time.now.month && x.day == Time.now.day
        'today'
      else
        x.strftime('%b %d')
      end
    else
      x.strftime('%b %d, %Y')
    end
  end
  
  def time_mdy(x)
    x = x - 560.seconds # TEMPORARY: REMOVE
    "#{mdy(x)} at #{time_time(x)}"
  end

  def time_mdy_smart(x)
    x = x - 560.seconds # TEMPORARY: REMOVE
    "#{mdy_smart(x)} at #{time_time(x)}"
  end


  def time_time(x)
    "#{x.hour % 12 == 0 ? 12 : x.hour % 12 }:#{x.min < 10 ? "0#{x.min}" : x.min}&nbsp;#{x.hour > 11 ? 'PM' : 'AM'}"
  end
  
  def pretty_delete_button(to, *opts)
    
    opts = opts.pop if opts
    check_perms = (!opts[:check].blank? && opts[:check]) || true
    opts.delete :check
    
    pretty_button("delete_#{to.class.name.underscore.dasherize.downcase}".to_sym,
                  easy_path_to(to),
                  "Delete #{to.class.name.titleize}",
                  :confirm => "Are you sure you want to delete the #{to.class.name.titleize.downcase}?",
                  :method => :delete,
                  *opts)
                  
  end
  
  def pretty_button(style, url, text, *opts)
    settings = ((opts[0] if opts.length > 0) || {}).merge({:class => "button-link #{style.to_s.dasherize}-button"})
    link_to(text, url, settings)
  end
  
  def pretty_button_if(bool, *args)
    pretty_button *args if bool
  end
  
  def phone(p)
    p = p.split('x').collect {|s| s.strip}
    p.map! {|q| q.gsub(/[^0-9]/, '').to_i }
    
    opts = {}
    opts[:area_code] = true if p[0] && p[0].to_s.size > 7
    opts[:extension] = p[1] unless p[1].blank?
    
    number_to_phone(p[0], opts)
  end
  
  def link_to_issuer(i)
    i = i.issuer if i.is_a? Update
    if i.is_a? Group
      link_to i.name, group_type_group_path(i.group_type, i)
    else
      link_to i.full_name, user_path(i)
    end
  end
  
  def list_from(items, ul_opts, li_opts)
    content_tag(:ul, ul_opts, nil, true) do
      inside = ''
      items.each do |i|
        content_tag :li, i, li_opts 
      end
    end
  end
  
  def easy_link_to(name, loc, *opts)
    link_to name, easy_path_to(loc), *opts
  end
  
  def easy_path_to(target)
    fmt = PATH_FORMATS[target.class.name]
    fun = (fmt.reverse.map {|p| p.to_s}).join('_')+"_path"
    args = []
    fmt.each do |p|
      if target.class.reflections.include?(p)
        target = target.send(p)
      elsif !params["#{p}_id"].blank?
        target = target.class.find(params["#{p}_id"])
      end
      args.unshift target.to_param
    end
    send fun.to_sym, *args
  end
  
  def preferred
    '<span class="tiny">&laquo;</span>'
  end
  def preferred_cell(user)
    preferred if user.preferred_is_cell
  end
  def preferred_desk(user)
    preferred if !user.preferred_is_cell
  end
  
  def scale_dimensions(w, h, within)
    if w > h
      [within, h*within/w]
    else
      [w*within/h, within]
    end
  end
  
  def humanize_number(n, trans_table = {}, context = '')
    translations = {
        0 => 'no',
        1 => (context == 'a') ? 'a' : 'an',
      }.merge(trans_table)
      
      translations[n] || n
  end

  def match_counter(updates)
    l = updates.length
    if l == 1:
      "1 match"
    else
      "#{l} matches"
    end
  end
  
  def simple_link_format(str)
    simple_format(auto_link(h(str), :html => { :target => '_blank' }))
  end

  # returns options for all of the groups, grouped into optgroups by group_type
  def group_select_options(groups,selected='')
    groups = groups.to_a.sort_by {|g| g.name}
    group_types = Set.new
    group_types.merge groups.collect {|g| g.group_type}
    group_types = group_types.to_a.sort_by {|g| g.name}.collect do |gt|
      gt.selected_groups = groups.select {|g| g.group_type == gt}
      gt
    end
    option_groups_from_collection_for_select(group_types, :selected_groups, 'name.pluralize', :id, :name, selected)
  end

  def tag_link_helper(tag,incident)
    link_to tag.name, "#{incident_updates_path(incident)}?tags_filter=#{tag.id}"
  end
end
