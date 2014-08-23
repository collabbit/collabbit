require 'zip/zipfilesystem'
require 'yaml'
require 'FileUtils'
class InstancesController < AuthorizedController
  
  before_filter :setup_editable_permissions, :only => [:update, :edit]
  
  def index
    @instances = Instance.all
    return with_rejection unless @current_user.can? :list => @instances
  end

  def show
    @incidents = @instance.incidents.find(:all,
                                          :include => [:updates],
                                          :order => 'created_at DESC',
                                          :conditions => ['created_at > ?', 2.months.ago.to_i])
    return with_rejection unless @current_user.can? :list => @incidents, :view => @instance
  end

  # Method for displaying the information needed on the 'Edit instance' page,
  # which lets the user edit the name of the instance and the permissions
  # associated with each role.
  # It passes the permissions to the view in a hash in which the
  # permissions are organized by their model.
  def edit
    return with_rejection unless @current_user.can? :update => @instance
    @roles = @instance.roles
  end

  # Updates an existing instance object in the database specified by its :id
  # The data to be saved is provided in the :instance hash,
  # which is populated by the form on the 'edit' page
  # It also saves the updated permissions to the database based
  # on the :permissions hash
  def update
    return with_rejection unless @current_user.can? :update => @instance
    
    if params[:permissions].is_a? Hash
      params[:permissions].each_pair do |role_id, rest|
        role = @instance.roles.find(role_id, :include => [:permissions, :privileges])
        rest.each_pair do |model_name, actions|
          to_delete = @perms_hash[model_name.gsub(/[a-z][A-Z]/) {|m| "#{m[0,1]} #{m[1,2]}"}] - actions.keys
          to_add = actions.keys - role.permissions.find_all_by_model(model_name).map(&:action)
          
          to_delete.each do |act|
            perm = role.permissions.find(:first, :conditions => {:model => model_name, :action => act})
            perm.privileges.find_by_role_id(role.id).destroy if perm
          end
          
          to_add.each do |act|
            role.permissions << Permission.find(:first, :conditions => {:model => model_name, :action => act})
          end
          
          role.save
        end
      end
    end
    if @instance.update_attributes(params[:instance])
      #flash[:notice] = t('notice.instance.updated')
      flash[:notice] = t('notice.instance_.updated')
      redirect_to edit_path
    else
      flash[:error] = t('error.instance.update_failed')
      render edit_path
    end
  end

  # Removes an instance object specified by its :id from the database
  def destroy
    return with_rejection unless @current_user.can? :destroy => @instance
    @instance.destroy
    redirect_to @instance
  end

  def new
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.new
  end

  # Saves an instance object to the database with the parameters provided in
  # the :instance hash, which is populated by the form on the 'new' page
  def create
    return with_rejection unless @current_user.can? :create => Instance
    @instance = Instance.build(params[:instance])
    if @instance.save
      flash[:notice] = t('notice.instance.created')
      redirect_to @instance
    else
      render :action => 'new'
    end
  end
 

  
#export a particular instance
#all the tables associated are exported in the form of yaml files and can be downloaded as zip 
   
def export
    
    #Export of Incidents to yaml file
    result_incidents=Incident.export_incidents(@instance)    

    #Export of Updates to yaml file
    result_updates = Update.export_updates(@instance)

    #Export of Comments into a yaml file
    result_comments = Comment.export_comments(@instance)
    
    #Export of Users to a yaml file
    result_users = User.export_users(@instance)
    
    #Export of Feeds to a yaml file
    result_feeds = Feed.export_feeds(@instance)
    
    #Export of Group Types to a yaml file
    result_group_types = GroupType.export_group_types(@instance)
    
    #Export of Groups to a yaml file
    result_groups = Group.export_groups(@instance)
    
    #Export of Roles to a yaml file
    result_roles = Role.export_roles(@instance)
        
    #Export of Tags to a yaml file
    result_tags = Tag.export_tags(@instance)
  
    #Export of WhiteListed Domains to a yaml file
    result_whitelisted_domains = WhitelistedDomain.export_whitelisted_domains(@instance)
    
    #Export of Attachments to a yaml file
    attachments = AttachedFile.attachedfilesarr(@instance)
   result_attachments = AttachedFile.export_attachments(@instance)
    
    #Export of Classifications to a yaml file
    result_classifications = Classification.export_classifications(@instance)
    
    #Export of Criterions to a yaml file
    result_criterions = Criterion.export_criterions(@instance)

    #Export of Group Taggings to a yaml file
     result_group_taggings = GroupTagging.export_group_taggings(@instance) 
     
     #Export of Taggings to a yaml file
     result_taggings = Tagging.export_taggings(@instance)

     #Export of Memberships to a yaml file
     result_memberships = Membership.export_memberships(@instance)
     
     
    #Creation of a Zip file
    @filename ="#{RAILS_ROOT}/tmp/#{@instance.short_name}.zip"

    #Open the zip file to add the files
    Zip::ZipOutputStream::open(@filename) do |zip|
    
      #Add Incidents to Zip
      zipentry(zip, "incidents", result_incidents)

      #Add Comments to Zip
      zipentry(zip, "comments", result_comments)
      
      #Add Updates to Zip
      zipentry(zip, "updates", result_updates)
      
      #Add Users to Zip
      zipentry(zip, "users", result_users)
      
      #Add Feeds to Zip
      zipentry(zip, "feeds", result_feeds)
      
      #Add Group types to Zip
      zipentry(zip, "group_types", result_group_types)

      #Add Groups to Zip
      zipentry(zip, "groups", result_groups)

      #Add Roles to Zip
      zipentry(zip, "roles", result_roles)

      #Add Tags to Zip
      zipentry(zip, "tags", result_tags)

      #Add Whitelisted Domains to Zip
      zipentry(zip, "whitelisted_domains", result_whitelisted_domains)
      
      #Add  Attachments to Zip 
      zipentry(zip, "attachments", result_attachments)

      #Add Classifications to Zip
      zipentry(zip, "classifications", result_classifications)

      #Add Criterions to Zip
      zipentry(zip, "criterions", result_criterions)

      #Add Group Taggings to Zip
      zipentry(zip, "group_tagings", result_group_taggings)

      #Add Taggings to Zip
      zipentry(zip, "taggings", result_taggings)

      #Add Memberships to Zip
      zipentry(zip, "memberships", result_memberships)
      
   end
    
#Add all the files in attachments in a separate folder 
    Zip::ZipFile::open(@filename) do |zip|
      zip.dir.mkdir("attachments")
      attachments.each do |a|
         zip.add("attachments/#{a.attach.original_filename}", a.attach.path)
      end
    end

    send_file @filename,  :type => 'application/zip',
                            :filename => "#{@instance.short_name}.zip",
                            :disposition => 'attachment'
  
end


#Import imports a particular instance and reproduces it
#All the relationships between various tables is maintained while importing

def import
   
   @dest ="#{RAILS_ROOT}/tmp/out"
   unless params[:zip_file].blank?
    FileUtils.rm_rf(Dir.glob("#{@dest}/*"))
    
    #Open a Zip File that is already present and read
    Zip::ZipFile::open(params[:zip_file].path) do |zipfile|    
       zipfile.each do |entry|
        f_path=File.join(@dest,entry.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zipfile.extract(entry,f_path) unless File.exist?(f_path)
       end
    end
  
    #Unzip and Import the Incidents File
    Incident
    Dir.chdir(@dest)
    @incidentfile = Dir.glob("*incidents.yaml")
    yfincidents = File.open(@incidentfile.to_s) 
    ydocs = YAML.load(yfincidents)

    ydocs.each do |ydoc|
      @instance.incidents.build(:name => "#{ydoc.name}", 
                                :description => "#{ydoc.description}")
      @instance.save
    end
        
    #Unzip and Import the User File
    User
    @usersfile = Dir.glob("*users.yaml")
      yfusers = File.open(@usersfile.to_s)
      users = YAML.load(yfusers)
      users.each do |user|
        u = @instance.users.build({:first_name => "#{user.first_name}", 
                             :last_name => "#{user.last_name}", 
                             :email => "#{user.email}", 
                             :desk_phone => "#{user.desk_phone}", 
                             :desk_phone_ext => "#{user.desk_phone_ext}", 
                             :cell_phone => "#{user.cell_phone}", 
                             :preferred_is_cell => "#{user.preferred_is_cell}",  
                             :state => "#{user.state}"})  
        @instance.save
        u.generate_salt!
        u.generate_crypted_password!
        u.generate_activation_code!
     
     
    
      Role
      @rolesfile = Dir.glob("*roles.yaml")
      yfroles = File.open(@rolesfile.to_s)
      roles = YAML.load(yfroles)
      role_name = nil
      roles.each do |role|
        if(user.role_id== role.id)
           role_name = role.name
           break
        end
      end
     
     
      @role = @instance.roles.find_by_name(role_name.to_s)
      u.role = @role
      u.save
     end
     
     #Unzip and Import the Tags File
     Tag
      @tagsfile = Dir.glob("*tags.yaml")
      yftags = File.open(@tagsfile.to_s)
      tags = YAML.load(yftags)
      
      tags.each do |tgs|
        @instance.tags.build(:name => "#{tgs.name}")
       @instance.save
      end
      
     #Unzip and Import the WhiteListedDomains File
     WhitelistedDomain
      @whitelisteddomainsfile = Dir.glob("*whitelisted_domains.yaml")
      yfwhitelisteddomains = File.open(@whitelisteddomainsfile.to_s)
      whitelisteddomains = YAML.load(yfwhitelisteddomains)
      
      whitelisteddomains.each do |wld|
        @instance.whitelisted_domains.build(:name => "#{wld.name}")
       @instance.save
      end
      
     #Unzip and Import the Updates File
     Update
     @updatesfile = Dir.glob("*updates.yaml")
     yfupdates = File.open(@updatesfile.to_s)
     updates = YAML.load(yfupdates)
     updates.each do |update|
       elem=-1
       ydocs.each do |ydoc|
         elem += 1
         break if ydoc.id == update.incident_id
       end  
       @incident=@instance.incidents.find_by_name(ydocs[elem].name.to_s)
       up = @incident.updates.build({:title => "#{update.title}", :text => "#{update.text}"})
      @incident.save
        
       e=-1
       users.each do |yd|
         e += 1
         break if yd.id == update.user_id
       end 
       user= @instance.users.find_by_email(users[e].email.to_s)
       up.user_id = user.id
       up.save
     end     
     
     #Unzip and Import the Comments File
     Comment
     @commentsfile = Dir.glob("*comments.yaml")
     yfcomments = File.open(@commentsfile.to_s)
     comments = YAML.load(yfcomments)
     
     comments.each do |cmt|
       cmtt = nil
       elem = -1
       updates.each do |upd|
         elem += 1
         cmtt = upd
         break if upd.id == cmt.update_id
       end
       
       ele = -1
       ydocs.each do |comm|
         ele += 1
         break if cmtt.incident_id == comm.id
       end
        
        use = -1
       users.each do |uss|
         use += 1
         break if cmt.user_id == uss.id
       end
       
       userrec = @instance.users.find_by_email(users[use].email.to_s)
       
       @incident = @instance.incidents.find_by_name(ydocs[ele].name.to_s)
       @update = @incident.updates.find_by_title(updates[elem].title.to_s)
       
       commnt = @update.comments.build(:body => "#{cmt.body}",:user_id => "#{userrec.id}")
       @update.save
    end
    
    #Unzip and Import the GroupTypes File
    GroupType
     @grouptypesfile = Dir.glob("*group_types.yaml")
     yfgrouptypes = File.open(@grouptypesfile.to_s)
     grouptypes = YAML.load(yfgrouptypes)
     
     grouptypes.each do |grt|
        grtype=@instance.group_types.build(:name => "#{grt.name}", :groups_count => "#{grt.groups_count}")
        @instance.save
     end
     
    #Unzip and Import the Groups File  
    Group
    groupsfile = Dir.glob("*groups.yaml")
    yfgroups = File.open(groupsfile.to_s)
    groups = YAML.load(yfgroups)
    groups.each do |grps|
       ct = -1
       grouptypes.each do |typ|
         ct += 1
         break if grps.group_type_id == typ.id
        end
    
    group_type = @instance.group_types.find_by_name(grouptypes[ct].name.to_s)
    group = group_type.groups.build(:name => "#{grps.name}")
    group_type.save
    end
    
    #Unzip and Import the Memberships File
    Membership
    memfile = Dir.glob("*memberships.yaml")
    yfmems = File.open(memfile.to_s)
    memships = YAML.load(yfmems)
    
    memships.each do |mems|
      ct = -1
      users.each do |user|
        ct+=1
        break if mems.user_id == user.id
      end
    
      cnt = -1
      groups.each do |group|
        cnt+=1
        break if mems.group_id == group.id
      end
      
      count = -1
      grouptypes.each do |gtype|
        count += 1
        break if gtype.id == groups[cnt].group_type_id
      end
      
    user = @instance.users.find_by_email(users[ct].email.to_s)
    grouptype = @instance.group_types.find_by_name(grouptypes[count].name.to_s)
    grp = grouptype.groups.find_by_name(groups[cnt].name.to_s)
    memship = user.memberships.build(:group_id => "#{grp.id}")
    user.save
    
    end
    #Unzip and Import the Classifications File
    Classification
    @classiffile = Dir.glob("*classifications.yaml")
    yfclassifs = File.open(@classiffile.to_s)
    classifs = YAML.load(yfclassifs)
  
    classifs.each do |classif|
    
    ct = -1
      groups.each do |grp|
        ct += 1
        break if grp.id == classif.group_id
      end
    
      count = -1
      grouptypes.each do |gtype|
        count +=1
        break if gtype.id == groups[ct].group_type_id
      end
 
   
      cnt = -1
      updates.each do |upd|
        cnt += 1
        break if upd.id == classif.update_id
      end
    
      cntt = -1
      ydocs.each do |inci|
          cntt += 1
          break if inci.id == updates[cnt].incident_id
      end
    
    grptype = @instance.group_types.find_by_name(grouptypes[count].name.to_s)
    group = grptype.groups.find_by_name(groups[ct].name.to_s)
    
    incident = @instance.incidents.find_by_name(ydocs[cntt].name.to_s)
    upd = incident.updates.find_by_title(updates[cnt].title.to_s)
    group.classifications.build(:update_id => "#{upd.id}")
    group.save
    end
  
     #Unzip and Import the Taggings File 
     Tagging
      @taggingsfile = Dir.glob("*taggings.yaml")
      yftaggings = File.open(@taggingsfile.to_s)
      taggings = YAML.load(yftaggings)
      
      taggings.each do |tggs|
        tg = -1
        tags.each do |ts|
          tg += 1
          break if ts.id == tggs.tag_id
        end
        
        ti = -1 
        updates.each do |upa|
          ti +=1
          break if upa.id == tggs.update_id
        end
        
        elem = -1
        ydocs.each do |inci|
          elem +=1
          break if inci.id == updates[ti].incident_id
        end
        
        inci= @instance.incidents.find_by_name(ydocs[elem].name.to_s)
        upd = inci.updates.find_by_title(updates[ti].title.to_s)
        
        @tag = @instance.tags.find_by_name(tags[tg].name.to_s)
        tagging = @tag.taggings.build(:update_id => "#{upd.id}")
        @tag.save
        
       end
     
    #Unzip and Import the Feeds File
    Feed
    @feedsfile = Dir.glob("*feeds.yaml")
    yffeeds = File.open(@feedsfile.to_s)
    feeds = YAML.load(yffeeds)
    
    feeds.each do |fds|
      fd = -1
      ydocs.each do |ins|
        fd += 1
        break if fds.incident_id == ins.id
      end
      
      u = -1
      users.each do |us|
        u += 1
        break if us.id = fds.owner_id
      end
   
    userr = @instance.users.find_by_email(users[u].email.to_s)
    
    
    @incid = @instance.incidents.find_by_name(ydocs[fd].name.to_s)
    feed = @incid.feeds.build(:name => "#{fds.name}", 
                              :description => "#{fds.description}", 
                              :text_alert => "#{fds.text_alert}",
                              :email_alert => "#{fds.email_alert}",
                              :owner_id => "#{userr.id}")
     @incid.save
   
    end
 
    #Unzip and Import the Group Taggings File
    GroupTagging
    @grouptaggingsfile = Dir.glob("*tagings.yaml")
    yfgrouptaggings = File.open(@grouptaggingsfile.to_s)
    grouptaggings = YAML.load(yfgrouptaggings)
    
    grouptaggings.each do |gtg|
      
      ele = -1
      tags.each do |ts|
        ele += 1
        break if ts.id == gtg.tag_id
      end
      
      gp = -1
      groups.each do |gps|
        gp += 1
        break if gps.id == gtg.group_id
      end
      
      elem = -1
        grouptypes.each do |grty|
          elem +=1
          break if grty.id == groups[gp].group_type_id
        end
      
      @grptyp = @instance.group_types.find_by_name(group_types[elem].name.to_s)
      grp = @grptyp.groups.find_by_name(groups[gp].name.to_s)
      
      @tag = @instance.tags.find_by_name(tags[ts].name.to_s)
      group_type = @tag.group_taggings.build(:group_id => "#{grp.id}")
      @tag.save
    end
    
    #Unzip and Import the Criterions File
    Criterion
    @criterionsfile = Dir.glob("*criterions.yaml")
    yfcriterions = File.open(@criterionsfile.to_s)
    criterions = YAML.load(yfcriterions)
    
    criterions.each do |crt|
      
      ct = -1
      feeds.each do |fd|
        ct += 1
        break if fd.id == crt.feed_id
      end
      
      ic = -1
      ydocs.each do |inc|
      ic += 1
        break if inc.id == feeds[ct].incident_id
      end
      
      @incd = @instance.incidents.find_by_name(ydocs[ic].name.to_s)
      @fed = @incd.feeds.find_by_name(feeds[ct].name.to_s)
      criter = @fed.criterions.build(:kind => "#{crt.kind}", :requirement => "#{crt.requirement}", :requirement => "#{crt.requirement}")
      @fed.save
      
    end
  
    #Unzip and Import the Attachments File
    AttachedFile
    @attfile = Dir.glob("*attachments.yaml")
    yfatt = File.open(@attfile.to_s)
    attaches = YAML.load(yfatt)
     
     attaches.each do |att|  
      el = -1
      up = nil
      updates.each do |updt|
        el += 1
        up = updt
        break if updt.id == att.update_id
       end
   
      elem=-1
      ydocs.each do |ydoc|
        elem += 1
        break if ydoc.id == up.incident_id
      end
     
      @incident = @instance.incidents.find_by_name(ydocs[elem].name.to_s)
      @update = @incident.updates.find_by_title(updates[el].title.to_s)
       
       attachment = @update.attached_files.build(:attach => File.new("attachments/#{att.attach_file_name}"))
      @update.save
   end
 end  
  redirect_to @instance
end

 private 
  def zipentry(zip, str,var)
    zip.put_next_entry ("#{@instance.short_name}_" + str + ".yaml")
    zip << var
  end

  protected
    def setup_editable_permissions
      crud = ['create', 'update', 'destroy']
      @perms_hash = { 'Update'      => crud,
                      'Comment'     => crud,
                      'User'        => crud,
                      'Group'       => crud,
                      'Group Type'  => crud,
                      'Incident'    => crud }
    end
end

