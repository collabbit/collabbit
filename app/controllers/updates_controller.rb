# Controller for operations on users in the database.  
#
# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class UpdatesController < ApplicationController
  def new
    @update = Update.new
    @incident = @instance.incidents.find(params[:incident_id])
    @tags = @instance.tags
    @groups = @instance.groups
    return with_rejection unless Update.creatable? and @instance.viewable?
  end

  def show
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @update.viewable? and @instance.viewable?
  end

  def edit
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @update.updatable? and @instance.viewable?
  end

  # Used for displaying the list of updates in a particular incident
  # Uses the mislav-will_paginate plugin
  # Documentation is available at: http://gitrdoc.com/mislav/will_paginate/tree/master/
  def index 
    @incident = @instance.incidents.find(params[:incident_id])
    @updates = @incident.updates.paginate :all,
                                          :page           => params[:page],
                                          :per_page       => 50,
                                          :order          => 'id DESC',
                                          :conditions     => search,
                                          :filters        => filters,
                                          :filter_style   => :and
    
    @group_filter = params[:filters] && 
                    !params[:filters][:relevant_groups].blank? &&
                    !params[:filters][:relevant_groups][:id].blank? &&
                    @instance.groups.find(params[:filters][:relevant_groups][:id])
    @tag_filter = params[:filters] &&  !params[:filters][:tags].blank? &&
                    !params[:filters][:tags][:id].blank? && 
                    @instance.groups.find(params[:filters][:tags][:id])
    @detail_level = params[:detail_level]                                      
    @search = params[:search] if params[:search] and params[:search].length > 0
    
    return with_rejection unless Update.listable? and @instance.viewable?
  end
  
  # Saves an update object to the database with the parameters provided in 
  # the :update hash, which is populated by the form on the 'new' page
  def create
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.build(params[:update])
    return with_rejection unless Update.creatable? and @instance.viewable?
    
    @update.incident = @incident
    @update.user = User.current

    unless params[:update][:issuer].blank? or params[:update][:issuer] == 'myself'
      @update.issuing_group = @instance.groups.find(params[:update][:issuer])
    end
    
    if params[:relevant_groups] 
      params[:relevant_groups].each_pair do |key,val|
        @update.relevant_groups << @instance.groups.find(key) if val
      end
    end
    
    @update.tags.clear
    if params[:tags]
      params[:tags].each_pair do |key,val|
        @update.tags << @instance.tags.find(key) if val
      end
    end
    
    # Uploaded files
    unless params[:attachments].blank? #and Attachment.creatable?
      params[:attachments].each do |attach|
        @update.attachments.build(:attach => attach)
      end
    end
    
    if @update.save
      flash[:notice] = UPDATE_CREATED
      redirect_to instance_incident_path(@instance, @incident)
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
    return with_rejection unless @update.updatable?

    @update.tags.clear
    if params[:tags]
      params[:tags].each_pair do |key,val|
        @update.tags << Tag.find(key) if val
      end
    end
    
    @update.attachment_ids = @update.attachment_ids & (params[:keep_file] || [])
    unless params[:attachments].blank? #and Attachment.creatable?
      params[:attachments].each do |attach|
        @update.attachments.build(:attach => attach)
      end
    end

    if @update.update_attributes(params[:update])
      flash[:notice] = UPDATE_UPDATED
      redirect_to instance_incident_update_path(@instance, @incident, @update)
    else
      render :action => 'new'
    end
  end
  
  # Removes an update object from the database
  def destroy  
    @incident = @instance.incidents.find(params[:incident_id])
    @update = @incident.updates.find(params[:id])
    return with_rejection unless @update.destroyable?
    @update.destroy
    redirect_to instance_incident_updates_path(@instance,@incident)
  end
  
  private
    # Returns an array of conditions for filtering contacts based on GET params
    def search
      return unless params[:search] and !params[:search].blank?
      values = {}
      fields = [:title, :text]
      query = (fields.map{|f| "#{f} LIKE :#{f}"}).join(" OR ")
      fields.each do |field|
        values[field] = "%#{params[:search]}%" 
      end      
      [query, values]
    end
    
    def filters
      params[:filters]
    end
  
end