class IncidentsController < AuthorizedController
  def new    
    @incident = Incident.new
    return with_rejection unless @current_user.can? :create => Incident
  end

  def show    
    @incident = @instance.incidents.find(params[:id])
    if(params[:group_filter]) 
        @group = @instance.groups.find(params[:group_filter]).name
    end
    if(params[:tags_filter])
        @tag = @instance.tags.find(params[:tags_filter]).name
    end
    @search_filtered_results = @incident.updates_search_filter(params[:search_query])
    @group_filtered_results = @incident.updates_group_filter(@group)
    @tag_filtered_results = @incident.updates_tag_filter(@tag)
    @filtered_updates = @group_filtered_results & @tag_filtered_results
    @filtered_updates = @filtered_updates & @search_filtered_results
    return with_rejection unless @current_user.can? :view => @incident
    
    respond_to do |format|
      format.html { redirect_to incident_updates_path(@incident) }
      format.text { render 'show.txt' }
      format.xml  { render :xml => @incident }
      format.pdf { render :layout => false }
    end
  end

  def edit    
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :update => @incident
  end

  def index
    @incidents = @instance.incidents.find(:all, :order => 'created_at DESC')
    return with_rejection unless @current_user.can? :list => @incidents
  end
  
  # Saves an incident object to the database with the parameters provided in 
  # the :incident hash, which is populated by the form on the 'new' page
  def create    
    @incident = @instance.incidents.build(params[:incident])
    return with_rejection unless @current_user.can? :create => Incident
        
    @instance.users.each do |u|
      f = Feed.make_my_groups_feed(@incident)
      f.owner = u
      f.save
    end

    if @incident.save
      flash[:notice] = t('notice.incident.created')
      redirect_to @incident
    else
      render :action => 'new'
    end
  end
  
  # Updates an existing incident object in the database specified by its :id
  # The data to be saved is provided in the :incident hash, 
  # which is populated by the form on the 'edit' page
  def update
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :update => @incident
    if @incident.update_attributes(params[:incident])
      flash[:notice] = t('notice.incident.updated')
      redirect_to @incident
    else
      render :action => 'new'
    end
  end
  
  # Removes an incident object specified by its :id from the database
  def destroy
    @incident = @instance.incidents.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @incident
    @incident.destroy
    redirect_to incidents_path
  end

  def close
    @incident = @instance.incidents.find(params[:incident_id])
    return with_rejection unless @current_user.can? :update => @incident
    
    if @incident.closed_at
      flash[:notice] = 'Incident reopened'
      @incident.closed_at = nil
      @incident.save
    else
      flash[:notice] = 'Incident closed'
      @incident.closed_at = DateTime.now
      @incident.save
    end
    
    redirect_to @incident
  end
end
