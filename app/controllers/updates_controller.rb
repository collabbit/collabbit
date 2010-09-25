class UpdatesController < AuthorizedController
  def new
    return with_rejection unless @current_user.can? :create => Update
    @update = Update.new
    @incident = @instance.incidents.find(params[:incident_id])
    @tags = @instance.tags
    @groups = @instance.groups
  end

  def show
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @current_user.can? :show => @update
  end

  def edit
    @incident = @instance.incidents.find(params[:incident_id])
    @tags = @instance.tags
    @groups = @instance.groups
    @update = @incident.updates.find(params[:id])    
    return with_rejection unless @current_user.can? :update => @update
  end
  
  def poll_for_newer
    incident = @instance.incidents.find(params[:incident_id])
    new_updates = incident.updates.find(:all, :select => 'id', :conditions => ['id > ?', params[:update_id].to_i])
    if new_updates.size > 0
      user_groups_updates = User.find(params[:user_id]).groups.inject(Set.new){|set, cur| set.merge cur.update_ids}
      user_diff = (user_groups_updates & new_updates.map(&:id)).size
      render :update do |page|
        size = new_updates.size

        updates = "There #{size == 1 ? 'is' : 'are'} #{humanize_number size, {},'a'} new update#{'s' if new_updates.size != 1}."
        yourgroups = user_diff > 0 ? "(#{user_diff} in your groups.)" : ''
        reload = "#{link_to 'Refresh', incident_updates_path(incident)} to see #{size == 1 ? 'it' : 'them'}."
        shadow = '<div id="shadow"></div>'
        hider = '<a id="hider" href="#">x</a>'
        page.replace_html 'new-updates-inner', "<div id=\"new-updates\">#{updates} #{yourgroups} #{reload} #{hider}</div>#{shadow}"
      end
    else
      render :text => ''
    end
  end

  # Used for displaying the list of updates in a particular incident
  # Uses the mislav-will_paginate plugin
  # Documentation is available at: http://gitrdoc.com/mislav/will_paginate/tree/master/
  def index
    @incident = @instance.incidents.find(params[:incident_id])

    return with_rejection unless @current_user.can? :list => @incident.updates

    @detail_level = params[:detail_level]
    
    search_clauses = {}
    
    unless params[:search].blank?
      @search = params[:search]
      search_clauses[:title_like_any_or_text_like_any] = @search.split(' ').map(&:strip)
    end
    
    unless params[:groups_filter].blank?
      @groups_filter = params[:groups_filter]
      unless @groups_filter == '' || @groups_filter == 'mine' || @groups_filter == nil
        @groups_filter = @groups_filter.to_i
      end
      # Eventually add in _or_issuing_group_id_
      search_clauses[:relevant_groups_id_equals_any] = case @groups_filter
        when 'mine' then @current_user.group_ids
        else [@groups_filter]
      end
    end

    unless params[:tags_filter].blank?
      search_clauses[:tags_id_is] = @tags_filter = params[:tags_filter].to_i
    end
    
    pagination_options = {
      :page => params[:page],
      :per_page => 50,
      :order => 'created_at DESC',
      :include => [:relevant_groups, :issuing_group, :tags]
    }    
    
    @searched = !search_clauses.blank?
    @all_updates = @incident.updates.search(search_clauses).uniq.sort_by {|u| -(u.created_at.to_i)}
    @updates = @all_updates.paginate(pagination_options)

    @comment = Comment.new
    @latest_update_id = Update.last.id
  end

  # Saves an update object to the database with the parameters provided in
  # the :update hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless @current_user.can? :create => Update

    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.build(params[:update])
    @update.user = @current_user
    @update.title.strip!

    unless params[:update][:issuer].blank? or params[:update][:issuer] == 'myself'
      @update.issuing_group = @instance.groups.find(params[:update][:issuer])
    end

    if params[:relevant_groups]
      params[:relevant_groups].each_pair do |key,val|
        @update.relevant_groups << @instance.groups.find(key) if val
      end
    end

    @update.tags.clear #<<FIX: why is this done? actually, it's okay if it doesn't make another query
    if params[:tags]
      params[:tags].each_pair do |key,val|
        @update.tags << @instance.tags.find(key) if val
      end
    end

    # Uploaded files
    unless params[:attachments].blank? #<<FIX: and @current_user.can? :create => Attachment ?
      params[:attachments].each do |attach|
        @update.attached_files.build(:attach => attach)
      end
    end

    if @update.save
      flash[:notice] = t('notice.update.created')
      redirect_to @incident
    else
      @tags = @instance.tags
      @groups = @instance.groups
      render :action => :new
    end
  end

  # Updates an existing update object in the database specified by its :id.
  # The data to be saved is provided in the :update hash,
  # which is populated by the form on the 'edit' page.
  def update
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @current_user.can? :update => @update

    @update.tags.clear
    if params[:tags]
      params[:tags].each_pair do |key,val|
        @update.tags << Tag.find(key) if val
      end
    end

    @update.relevant_groups.clear
    if params[:relevant_groups]
      params[:relevant_groups].each_pair do |key,val|
        @update.relevant_groups << Group.find(key) if val
      end
    end

    keep_ids = []
    (params[:keep_file] || {}).each_pair {|k,v| keep_ids << k.to_i if v}
    @update.attached_file_ids = @update.attached_file_ids & keep_ids
    unless params[:attachments].blank? #and Attachment.creatable_by?(@current_user)
      params[:attachments].each do |attach|
        @update.attached_files.build(:attach => attach)
      end
    end

    if @update.update_attributes(params[:update])
      flash[:notice] = t('notice.update.updated')
      redirect_to incident_update_path(@incident, @update)
    else
      render :action => 'new'
    end
  end

  # Removes an update object from the database
  def destroy
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @update
    @update.destroy
    redirect_to incident_updates_path(@incident)
  end
end

