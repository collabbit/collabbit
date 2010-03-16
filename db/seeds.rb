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
    :user       => actions,
    :instance   => [:show, :update],
    :comment    => actions
  }

model_to_actions.each_pair do |klass,v|
  v.each do |act|
    Permission.create(:model => klass.to_s.camelize, :action => act.to_s)
  end
end

#Default Instances
i = Instance.create(:long_name => 'Demo Instance')
i.short_name = 'demo'
i.roles = Role.default_setup
i.save

#Default Incidents
evil = i.incidents.create(:name => 'Evil Earthquake')
flood = i.incidents.create(:name => 'Faketown Flood')

#Default Group Types
agency = i.group_types.create(:name => 'Agency')
committee = i.group_types.create(:name => 'Committee')

# Default Users

john = i.users.create(
  :first_name => 'John', :last_name => 'Smith',
  :email => 'blah@blah.com', :activation_code => '111',
  :cell_phone => '5857704551', :preferred_is_cell => true)
jane = i.users.create(
  :first_name => 'Jane', :last_name => 'Smith',
  :email => 'blah2@blah.com', :activation_code => '121')
joey = i.users.create(
  :first_name => 'Joey', :last_name => 'Arnold',
  :email => 'blah3@blah.com', :activation_code => '131')

john.salt = Digest::SHA1.hexdigest('1')
john.crypted_password = john.generate_crypted_password('sahana123')
john.role = i.roles.find_by_name('Super Administrator')
john.state = 'active'
john.save

jane.salt = Digest::SHA1.hexdigest('2')
jane.crypted_password = jane.generate_crypted_password('sahana123')
jane.role = i.roles.find_by_name('Normal User')
jane.state = 'active'
jane.save

joey.salt = Digest::SHA1.hexdigest '1'
john.role = i.roles.find_by_name('Administrator')
joey.crypted_password = joey.generate_crypted_password('sahana123')
joey.state = 'active'
joey.save

# Default Groups
g1 = agency.groups.create(:name => 'Red Cross')
g2 = agency.groups.create(:name => 'FBI')
g3 = committee.groups.create(:name => 'City Hall')

# Default Updates
up1 = evil.updates.create(:title => 'First Update! YAY',
                        :text => 'We have it all under control... nbd...',
                        :issuing_group => g1)
up1.user = john


up2 = evil.updates.create(:id => 2, :title => 'Nevermind!',
                        :text => "I guess we don't really have it under control.. sowwy...",
                        :issuing_group => g2)
up2.user = john


up3 = flood.updates.create(:id => 3, :title => 'Cost update',
                        :text => 'The cost of this incident has now exceeded one billion gagillion fafillion... yen')
up3.user = jane


up4 = evil.updates.create(:id => 4, :title => 'MOAR Volunteers!',
                        :text => 'We have a dire need for volunteers on this incident!')
up4.user = jane


up5 = evil.updates.create(:id => 5, :title => 'Animals problem', :text => 'Lots of animals need shelter!', :group_id => 3)
up5.user = jane


up6 = evil.updates.create(:id => 6, :title => 'Food needed!',
                        :text => 'We need more food to distribute! Please help!',
                        :group_id => 2)
up6.user = jane  


#Default Tags
t1 = i.tags.create(:name => "GOVT")
t2 = i.tags.create(:name => "NGO")
t3 = i.tags.create(:name => "Important")
t4 = i.tags.create(:name => "Bronx")
t5 = i.tags.create(:name => "Queens")
t6 = i.tags.create(:name => "Good News")

#Default Admins
a = Admin.create(:email => 'blabla@bla.bla')
b = Admin.create(:email => 'blahblah@blah.blah')

a.salt = Digest::SHA1.hexdigest('bla')
a.crypted_password = a.generate_crypted_password('sahana123')
a.save
b.salt = Digest::SHA1.hexdigest('blah')
b.crypted_password = b.generate_crypted_password('sahana123')
b.save


#Default Carriers
Carrier.create(:name => 'AT&T', :extension => '@txt.att.net')
Carrier.create(:name => 'Boost', :extension => '@myboostmobile.com')
Carrier.create(:name => 'Cricket', :extension => '@sms.mycricket.com')
Carrier.create(:name => 'Nextel', :extension => '@messaging.nextel.com')
Carrier.create(:name => 'T-Mobile', :extension => '@tmomail.net')
Carrier.create(:name => 'Virgin Mobile', :extension => '@vmobl.com')
Carrier.create(:name => 'Verizon', :extension => '@vtext.com')
Carrier.create(:name => 'Sprint', :extension => '@messaging.sprintpcs.com')
Carrier.create(:name => 'Alltel Wireless', :extension => '@message.alltel.com')


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

User.all.each do |u|
  u.instance.incidents.each do |i|
    f = Feed.make_my_groups_feed(i)
    f.owner = u
    f.save
  end
end

UpdateObserver.enable!
UserObserver.enable!