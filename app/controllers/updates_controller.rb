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
    @incident = @instance.incidents.find(params[:incident_id], :include => [:updates])

    return with_rejection unless @current_user.can? :list => @incident.updates

    fs = {}
    if params[:filters]
      if params[:filters][:relevant_groups]
        gf = params[:filters][:relevant_groups][:id]
        if gf == 'mine'
          @group_filter = 'mine'
          fs[:relevant_groups] = {:id => @current_user.group_ids.join(",")}
        elsif gf.blank?
          @group_filter = nil
        else
          @group_filter = @instance.groups.find(gf)
          fs[:relevant_groups] = {:id => gf}
        end
      end
      if params[:filters][:tags]
        @tag_filter = params[:filters][:tags][:id]
        fs[:tags] = {:id => @tag_filter} unless @tag_filter.blank?
      end
    end

    @detail_level = params[:detail_level]
    @search = params[:search] if params[:search] and params[:search].length > 0

    conditions = {
      :page           => params[:page],
      :per_page       => 50,
      :order          => 'created_at DESC',
      :conditions     => search,
      :include        => [:relevant_groups, :issuing_group, :tags],
      :finder         => 'find_with_filters',
      :filters        => filters(fs)
    }
    @updates = @incident.updates.paginate(:all, conditions)
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

    @update.attachment_ids = @update.attachment_ids & (params[:keep_file] || [])
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

  private
    # Returns an array of conditions for filtering contacts based on GET params
    def search
      return unless params[:search] && !params[:search].blank?
      values = {}
      fields = [:title, :text]
      query = (fields.map{|f| "#{f} LIKE :#{f}"}).join(" OR ")
      fields.each do |field|
        values[field] = "%#{params[:search]}%"
      end
      [query, values]
    end

    def filters(fs)
      proper_arrayize(fs)
    end

    def proper_arrayize(x)
      x.each_key {|y|
        if x[y].is_a? Hash
          x[y] = proper_arrayize(x[y])
        elsif x[y][','] != nil
          x[y] = x[y].split(',')
        end
      }
      x
    end

end

