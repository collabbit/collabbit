UserObserver.disable!
UpdateObserver.disable!

#Generate Permissions
actions = [:create, :show, :list, :destroy, :update]
model_to_actions = {
    :update     => actions,
    :group      => actions,
    :group_type => actions,
    :tag        => actions,
    :incident   => actions,
    :role       => actions,
    :user       => actions - [:create],
    :instance   => [:show, :update],
    :comment    => actions
  }

model_to_actions.each_pair do |klass,v|
  v.each do |act|
    Permission.create(:model => klass.to_s.camelize, :action => act.to_s)
  end
end

#Default Instances
i = Instance.create(:short_name => 'demo', :long_name => 'Demo Instance')
i.roles = Role.default_setup
i.save

#Default Incidents
evil = Incident.create(:name => 'Evil Earthquake', :instance => i)
flood = Incident.create(:name => 'Faketown Flood', :instance => i)

#Default Group Types
agency = GroupType.create(:name => 'Agency', :instance => i)
committee = GroupType.create(:name => 'Committee', :instance => i)

# Default Users

john = User.create(
  :first_name => 'John', :last_name => 'Smith',
  :instance => i, :email => 'blah@blah.com', :activation_code => '111',
  :state => 'active', :cell_phone => '5857704551', :preferred_is_cell => true)
jane = User.create(
  :first_name => 'Jane', :last_name => 'Smith',
  :instance => i, :email => 'blah2@blah.com', :activation_code => '121',
  :state => 'active')
joey = User.create(
  :first_name => 'Joey', :last_name => 'Arnold',
  :instance => i, :email => 'blah3@blah.com', :activation_code => '131',
  :state => 'active')

john.salt = Digest::SHA1.hexdigest('1')
john.crypted_password = john.generate_crypted_password('sahana123')
john.role = i.roles.find_by_name('Super Administrator')
john.save

jane.salt = Digest::SHA1.hexdigest('2')
jane.crypted_password = jane.generate_crypted_password('sahana123')
jane.role = i.roles.find_by_name('Normal User')
jane.save

joey.salt = Digest::SHA1.hexdigest '1'
john.role = i.roles.find_by_name('Administrator')
joey.crypted_password = joey.generate_crypted_password('sahana123')
joey.save

# Default Groups
g1 = Group.create(:name => 'Red Cross',  :group_type => agency)
g2 = Group.create(:name => 'FBI',        :group_type => agency)
g3 = Group.create(:name => 'City Hall',  :group_type => committee)

# Default Updates
up1 = Update.create(:id => 1, :title => 'First Update! YAY',
                        :text => 'We have it all under control... nbd...',
                        :user_id => 1, :incident => evil, :issuing_group => g1)

up2 = Update.create(:id => 2, :title => 'Nevermind!',
                        :text => "I guess we don't really have it under control.. sowwy...",
                        :user_id => 1, :incident => evil, :issuing_group => g2)

up3 = Update.create(:id => 3, :title => 'Cost update',
                        :text => 'The cost of this incident has now exceeded one billion gagillion fafillion... yen',
                        :user_id => 2, :incident => flood)

up4 = Update.create(:id => 4, :title => 'MOAR Volunteers!',
                        :text => 'We have a dire need for volunteers on this incident!',
                        :user_id => 2, :incident => evil)

up5 = Update.create(:id => 5, :title => 'Animals problem', :text => 'Lots of animals need shelter!',
                        :user_id => 1, :incident => evil, :group_id => 3)

up6 = Update.create(:id => 6, :title => 'Food needed!',
                        :text => 'We need more food to distribute! Please help!',
                        :user_id => 2, :incident => evil, :group_id => 2)


#Default Tags
t1 = Tag.create(:id => 1, :name => "GOVT",      :instance => i)
t2 = Tag.create(:id => 2, :name => "NGO",       :instance => i)
t3 = Tag.create(:id => 3, :name => "Important", :instance => i)
t4 = Tag.create(:id => 4, :name => "Bronx",     :instance => i)
t5 = Tag.create(:id => 5, :name => "Queens",    :instance => i)
t6 = Tag.create(:id => 6, :name => "Good News", :instance => i)

#Default Admins
a = Admin.create(:id => 1, :email => 'blabla@bla.bla')
b = Admin.create(:id => 2, :email => 'blahblah@blah.blah')

a.salt = Digest::SHA1.hexdigest('bla')
a.crypted_password = a.generate_crypted_password('sahana123')
a.save
b.salt = Digest::SHA1.hexdigest('blah')
b.crypted_password = b.generate_crypted_password('sahana123')
b.save


#Default Carriers
Carrier.create(:id => 1, :name => 'AT&T', :extension => '@txt.att.net')
Carrier.create(:id => 2, :name => 'Boost', :extension => '@myboostmobile.com')
Carrier.create(:id => 3, :name => 'Cricket', :extension => '@sms.mycricket.com')
Carrier.create(:id => 4, :name => 'Nextel', :extension => '@messaging.nextel.com')
Carrier.create(:id => 5, :name => 'T-Mobile', :extension => '@tmomail.net')
Carrier.create(:id => 6, :name => 'Virgin Mobile', :extension => '@vmobl.com')
Carrier.create(:id => 7, :name => 'Verizon', :extension => '@vtext.com')
Carrier.create(:id => 8, :name => 'Sprint', :extension => '@messaging.sprintpcs.com')
Carrier.create(:id => 9, :name => 'Alltel Wireless', :extension => '@message.alltel.com')


#Linking Groups Users
g1.users << john
g1.users << jane
g2.users << jane
g3.users << john

g1.chairs << john
g1.chairs << jane
g2.chairs << john
g3.chairs << jane

g1.save
g2.save
g3.save

#Linking Update | Tag | Group
up1.relevant_groups << g1
up1.relevant_groups << g2
up2.relevant_groups << g1
up2.relevant_groups << g2
up2.relevant_groups << g3
up3.relevant_groups << g2
up3.relevant_groups << g1
up4.relevant_groups << g2
up4.relevant_groups << g3
up5.relevant_groups << g1
up6.relevant_groups << g2
up6.relevant_groups << g3

up1.issuing_group = g1
up4.issuing_group = g2

up1.tags << t1
up1.tags << t4
up1.tags << t3
up2.tags << t2
up3.tags << t6
up3.tags << t5
up4.tags << t4
up4.tags << t2
up4.tags << t3
up5.tags << t4
up5.tags << t1
up6.tags << t2

up1.save
up2.save
up3.save
up4.save
up5.save
up6.save

UpdateObserver.enable!
UserObserver.enable!