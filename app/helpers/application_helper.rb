# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
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
  
  def title(*args)
    args.flatten.concat(['Collabbit']).join(' &laquo; ')
  end
  
  #month day, year
  def mdy(x)
    x.strftime('%b %d, %Y')
  end
  
  def time_mdy(x)
    x.strftime('%I:%M%p ').downcase + mdy(x)
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
                  *opts) if !check_perms || to.destroyable?
                  
  end
  
  def pretty_button(style, url, text, *opts)
    settings = ((opts[0] if opts.length > 0) || {}).merge({:class => "button-link #{style.to_s.dasherize}-button"})
    link_to(text, url, settings)
  end
  
  def pretty_button_if(bool, *args)
    pretty_button *args if bool
  end
  
  def phone(p)
    p = p.split(' x ')
    number_to_phone(p[0], :extension => (p[1] unless p[1].blank?), :area_code => true)
  end
  
  def link_to_issuer(i)
    i = i.issuer if i.is_a? Update
    if i.is_a? Group
      link_to i.name, instance_group_type_group_path(i.group_type.instance, i.group_type, i)
    else
      link_to i.full_name, instance_user_path(i.instance, i)
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
      
end