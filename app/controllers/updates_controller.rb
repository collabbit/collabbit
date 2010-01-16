# Controller for operations on users in the database.
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

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
      search_clauses[:title_or_text_like_any] = @search.split(' ')
    end
    
    unless params[:groups_filter].blank?
      @groups_filter = params[:groups_filter]
      @groups_filter = @groups_filter.to_i unless @groups_filter == '' || @groups_filter == 'mine' || @groups_filter == nil
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
    @updates = @incident.updates.search(search_clauses).paginate(pagination_options)
  end

  # Saves an update object to the database with the parameters provided in
  # the :update hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless @current_user.can? :create => Update

    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.build(params[:update])
    @update.user = @current_user

    unless params[:update][:issuer].blank? or params[:update][:issuer] == 'myself'
      @update.issuing_group = @instance.groups.find(params[:update][:issuer])
    end

    if params[:relevant_groups]
      params[:relevant_groups].each_pair do |key,val|
        @update.relevant_groups << @instance.groups.find(key) if val
      end
    end

    @update.tags.clear #<<FIX: why is this done?
    if params[:tags]
      params[:tags].each_pair do |key,val|
        @update.tags << @instance.tags.find(key) if val
      end
    end

    # Uploaded files
    unless params[:attachments].blank? #<<FIX: and @current_user.can? :create => Attachment ?
      params[:attachments].each do |attach|
        @update.attachments.build(:attach => attach)
      end
    end

    if @update.save
      flash[:notice] = t('notice.update_created')
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
    logger.info("\n\n\n\n\nkids: #{keep_ids}\n\n\n\n\n")
    @update.attachment_ids = @update.attachment_ids & keep_ids
    logger.info("\n\n\n\n\naids: #{@update.attachment_ids}\n\n\n\n\n")
    unless params[:attachments].blank? #and Attachment.creatable_by?(@current_user)
      params[:attachments].each do |attach|
        @update.attachments.build(:attach => attach)
      end
    end

    if @update.update_attributes(params[:update])
      flash[:notice] = t('notice.update_updated')
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

