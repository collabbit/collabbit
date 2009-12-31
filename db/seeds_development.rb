require File.join(RAILS_ROOT, 'lib', 'create_or_update')

#Generate Permissions
Permission.generate_all

#Default Instances
Instance.create_or_update(:id => 1, :short_name => 'demo', :long_name => 'Demo Instance')


#Default Incidents
Incident.create_or_update(:id => 1, :name => 'Evil Earthquake', :instance_id => 1)
Incident.create_or_update(:id => 2, :name => 'Faketown Flood', :instance_id => 1)

#Default Group Types
GroupType.create_or_update(:id => 1, :name => 'Agency', :instance_id => 1)
GroupType.create_or_update(:id => 2, :name => 'Committee', :instance_id => 1)

# Default Users
UserObserver.disable!

john = User.create_or_update(
  :id => 1, :first_name => 'John', :last_name => 'Smith',
  :instance_id => 1, :email => 'blah@blah.com', :activation_code => '111',
  :state => 'active', :cell_phone => '5857704551', :preferred_is_cell => true)
jane = User.create_or_update(
  :id => 2, :first_name => 'Jane', :last_name => 'Smith',
  :instance_id => 1, :email => 'blah2@blah.com', :activation_code => '121',
  :state => 'active')
joey = User.create_or_update(
  :id => 3, :first_name => 'Joey', :last_name => 'Arnold',
  :instance_id => 1, :email => 'blah3@blah.com', :activation_code => '131',
  :state => 'active')

john.salt = Digest::SHA1.hexdigest('1')
john.crypted_password = john.generate_crypted_password('sahana123')
john.role = Instance.first.roles.find_by_name('Super Administrator')
john.save

jane.salt = Digest::SHA1.hexdigest('2')
jane.crypted_password = jane.generate_crypted_password('sahana123')
jane.role = Instance.first.roles.find_by_name('Normal User')
jane.save

joey.salt = Digest::SHA1.hexdigest '1'
john.role = Instance.first.roles.find_by_name('Administrator')
joey.crypted_password = joey.generate_crypted_password('sahana123')
joey.save

UserObserver.enable!

# Default Groups
g1 = Group.create_or_update(:id => 1, :name => 'Red Cross',  :group_type_id => 1)
g2 = Group.create_or_update(:id => 2, :name => 'FBI',        :group_type_id => 1)
g3 = Group.create_or_update(:id => 3, :name => 'City Hall',  :group_type_id => 2)

# Default Updates
UpdateObserver.disable!
up1 = Update.create_or_update(:id => 1, :title => 'First Update! YAY',
                        :text => 'We have it all under control... nbd...',
                        :user_id => 1, :incident_id => 1, :group_id => 1)

up2 = Update.create_or_update(:id => 2, :title => 'Nevermind!',
                        :text => "I guess we don't really have it under control.. sowwy...",
                        :user_id => 1, :incident_id => 1, :group_id => 1)

up3 = Update.create_or_update(:id => 3, :title => 'Cost update',
                        :text => 'The cost of this incident has now exceeded one billion gagillion fafillion... yen',
                        :user_id => 2, :incident_id => 2)

up4 = Update.create_or_update(:id => 4, :title => 'MOAR Volunteers!',
                        :text => 'We have a dire need for volunteers on this incident!',
                        :user_id => 2, :incident_id => 1)

up5 = Update.create_or_update(:id => 5, :title => 'Animals problem', :text => 'Lots of animals need shelter!',
                        :user_id => 1, :incident_id => 1, :group_id => 3)

up6 = Update.create_or_update(:id => 6, :title => 'Food needed!',
                        :text => 'We need more food to distribute! Please help!',
                        :user_id => 2, :incident_id => 1, :group_id => 2)

UpdateObserver.enable!


#Default Tags
t1 = Tag.create_or_update(:id => 1, :name => "GOVT",      :instance_id => 1)
t2 = Tag.create_or_update(:id => 2, :name => "NGO",       :instance_id => 1)
t3 = Tag.create_or_update(:id => 3, :name => "Important", :instance_id => 1)
t4 = Tag.create_or_update(:id => 4, :name => "Bronx",     :instance_id => 1)
t5 = Tag.create_or_update(:id => 5, :name => "Queens",    :instance_id => 1)
t6 = Tag.create_or_update(:id => 6, :name => "Good News", :instance_id => 1)

#Default Admins
a = Admin.create_or_update(:id => 1, :email => 'blabla@bla.bla')
b = Admin.create_or_update(:id => 2, :email => 'blahblah@blah.blah')

a.salt = Digest::SHA1.hexdigest('bla')
a.crypted_password = a.generate_crypted_password('sahana123')
a.save
b.salt = Digest::SHA1.hexdigest('blah')
b.crypted_password = b.generate_crypted_password('sahana123')
b.save


#Default Carriers
Carrier.create_or_update(:id => 1, :name => 'AT&T', :extension => '@txt.att.net')
Carrier.create_or_update(:id => 2, :name => 'Boost', :extension => '@myboostmobile.com')
Carrier.create_or_update(:id => 3, :name => 'Cricket', :extension => '@sms.mycricket.com')
Carrier.create_or_update(:id => 4, :name => 'Nextel', :extension => '@messaging.nextel.com')
Carrier.create_or_update(:id => 5, :name => 'T-Mobile', :extension => '@tmomail.net')
Carrier.create_or_update(:id => 6, :name => 'Virgin Mobile', :extension => '@vmobl.com')
Carrier.create_or_update(:id => 7, :name => 'Verizon', :extension => '@vtext.com')
Carrier.create_or_update(:id => 8, :name => 'Sprint', :extension => '@messaging.sprintpcs.com')
Carrier.create_or_update(:id => 9, :name => 'Alltel Wireless', :extension => '@message.alltel.com')


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

UpdateObserver.disable!
UserObserver.disable!
up1.save
up2.save
up3.save
up4.save
up5.save
up6.save

UpdateObserver.enable!
UserObserver.enable!

