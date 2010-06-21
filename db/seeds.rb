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

# Default Users
u1 = i.users.create(
  :first_name => 'John', :last_name => 'Super',
  :email => 'test1@collabbit.org', :activation_code => '111')
u2 = i.users.create(
  :first_name => 'Jane', :last_name => 'Admin',
  :email => 'test2@collabbit.org', :activation_code => '121')
u3 = i.users.create(
  :first_name => 'Joey', :last_name => 'User',
  :email => 'test3@collabbit.org', :activation_code => '131')

u1.salt = Digest::SHA1.hexdigest('1')
u1.crypted_password = u1.generate_crypted_password('demo')
u1.role = i.roles.find_by_name('Super Administrator')
u1.state = 'active'
u1.save

u2.salt = Digest::SHA1.hexdigest('2')
u2.crypted_password = u2.generate_crypted_password('demo')
u2.role = i.roles.find_by_name('Administrator')
u2.state = 'active'
u2.save

u3.salt = Digest::SHA1.hexdigest '1'
u3.role = i.roles.find_by_name('Normal User')
u3.crypted_password = u3.generate_crypted_password('demo')
u3.state = 'active'
u3.save


# lets make some fake people...
first_names = %w[
  James John Robert Michael William David Richard Charles Joseph Thomas Chris Daniel Paul
  Mark Donald George Kenneth Steven Edward Brian Ronald Anthony Kevin Jason Matthew Gary
  Mary Patricia Linda Barbara Elizabeth Jennifer Maria Susan Margaret Dorothy Lisa Nancy
  Karen Betty Helen Sandra Donna Carol Ruth Sharon Michelle Laura Sarah Kimberly Deborah]

last_names = %w[
  Smith Johnson Williams Brown Jones Miller Davis Garcia Rodriguez Wilson Martinez Anderson
  Taylor Thomas Hernandez Moore Martin Jackson Thompson White Lopez Lee Gonzalez Harris
  Clark Lewis Robinson Walker Hall Young Allen Sanchez Wright King Scott Green Baker Adams
  Nelson Hill Ramirez Campbell Mitchell Roberts Carter Phillips Evans Turner Torres Parker]

def gen_email(first_name,last_name)
  attempts = []
  attempts << "#{first_name[0,1]}#{last_name}"
  attempts << "#{first_name}.#{last_name}"
  attempts << "#{first_name}#{last_name}"
  "#{attempts[rand(attempts.size)]}@example.com".downcase
end

# use all last names at least once, and a couple twice
last_names_to_use = last_names.sort_by {rand} + last_names.sort_by {rand}[0,rand(9)+2]
last_names_to_use.each_with_index do |last_name,index|
  first_name = first_names[rand(first_names.size)]
  email = gen_email(first_name,last_name)
  # 555-01xx are reserved for fictional use in the US 
  #   there will be some number overlap, but we'll
  #   never call/text real numbers by accident
  phone_number = "55555501#{'0' if (index % 100) < 10}#{index % 100}"
  user = i.users.create(
    :first_name => first_name,
    :last_name => last_name,
    :email => email,
    :activation_code => index)

  # because people don't always capitalize correctly...
  if rand(30) == 0
    user.first_name = user.first_name.downcase
    user.last_name = user.last_name.downcase
  elsif rand(30) == 0
    user.first_name = user.first_name.upcase
    user.last_name = user.last_name.upcase
  end

  user.preferred_is_cell = [true,false][rand(2)]
  user.cell_phone = phone_number if  user.preferred_is_cell || rand(3) == 0
  user.desk_phone = phone_number if !user.preferred_is_cell || rand(3) == 0
  user.desk_phone_ext = (1..4).collect { rand(10) }.join if user.desk_phone && rand(3) == 0
  
  user.salt = Digest::SHA1.hexdigest('1')
  user.crypted_password = user.generate_crypted_password('demo')
  user.role = i.roles.find_by_name("Normal User")
  user.state = 'active'

  user.save
end

#Default Incidents
evil = i.incidents.create(:name => 'Evil Earthquake')
flood = i.incidents.create(:name => 'Faketown Flood')

# Default Group Types
groups = {
  'Agency' =>             ['City Harvest', 'Clothing Bank',
                           'Housing Servies', 'Homeless Services'],
  'Tech Support' =>       ['HFOSS'],
  'Emergency Support' =>  ['Agriculture and Natural Resources', 'Communications',
                           'Emergency Management', 'Energy', 'External Affairs',
                           'Logistics', 'Hazardous Materials Cleanup'],
  'City' =>               ['Police Department', 'Fire Department', 'Water Services',
                           'Mayor\'s Office', 'City Council']}

groups.each_key do |group_type|
  gt = i.group_types.create(:name => group_type)
  groups[group_type].each do |group|
    gt.groups.create(:name => group)
  end
end


#Default Group Types
agency = i.group_types.create(:name => 'Agency.Old')
committee = i.group_types.create(:name => 'Committee.Old')



# Default Groups
g1 = agency.groups.create(:name => 'Red Cross')
g2 = agency.groups.create(:name => 'FBI')
g3 = committee.groups.create(:name => 'City Hall')

# Default Updates
up1 = evil.updates.create(:title => 'First Update! YAY',
                        :text => 'We have it all under control... nbd...',
                        :issuing_group => g1)
up1.user = u1


up2 = evil.updates.create(:id => 2, :title => 'Nevermind!',
                        :text => "I guess we don't really have it under control.. sowwy...",
                        :issuing_group => g2)
up2.user = u1


up3 = flood.updates.create(:id => 3, :title => 'Cost update',
                        :text => 'The cost of this incident has now exceeded one billion gagillion fafillion... yen')
up3.user = u2


up4 = evil.updates.create(:id => 4, :title => 'MOAR Volunteers!',
                        :text => 'We have a dire need for volunteers on this incident!')
up4.user = u2


up5 = evil.updates.create(:id => 5, :title => 'Animals problem', :text => 'Lots of animals need shelter!', :group_id => 3)
up5.user = u2


up6 = evil.updates.create(:id => 6, :title => 'Food needed!',
                        :text => 'We need more food to distribute! Please help!',
                        :group_id => 2)
up6.user = u2  


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
g1.users << u1
g1.users << u2
g2.users << u2
g3.users << u1

g1.chairs << u1
g1.chairs << u2
g2.chairs << u1
g3.chairs << u2

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
