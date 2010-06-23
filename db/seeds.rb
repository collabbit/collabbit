UserObserver.disable!
UpdateObserver.disable!

# Generate Default Permissions
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


# Default Demo Instance
i = Instance.create(:long_name => 'Demo Instance')
i.short_name = 'demo'
i.roles = Role.default_setup
i.save


# Default Groups and Group Types
group_names={'Agency' => ['City Harvest', 'Clothing Bank', 'Power Plant',
                          'Housing Services', 'Homeless Services'],
       'Tech Support' => ['HFOSS'],
  'Emergency Support' => ['Agriculture and Natural Resources', 'Communications',
                          'Emergency Management', 'Energy', 'External Affairs',
                          'Logistics', 'Hazardous Materials Cleanup'],
               'City' => ['Police Department', 'Fire Department', 'Water Services',
                          'Mayor\'s Office', 'City Hall', 'Park Services',
                          'Department of Roads', 'Emergency Services']}

group_types = {}
groups = {}

group_names.each_key do |group_type|
  gt = i.group_types.create(:name => group_type)
  group_types[group_type] = gt
  group_names[group_type].each do |group|
    g = gt.groups.create(:name => group)
    groups[group] = g
  end
end


# Default Users (for testing)
default_users = [
  {:first_name => 'John',:last_name => 'Super',:email => 'test1@collabbit.org'},
  {:first_name => 'Jane',:last_name => 'Admin',:email => 'test2@collabbit.org'},
  {:first_name => 'Joey',:last_name => 'User', :email => 'test3@collabbit.org'}]
users = default_users.collect { |u| i.users.create(u) }

users[0].role = i.roles.find_by_name('Super Administrator')
users[1].role = i.roles.find_by_name('Administrator')
users[2].role = i.roles.find_by_name('Normal User')

users.each do |u|
  u.generate_salt!
  u.generate_activation_code!
  u.generate_crypted_password!('test')
  u.state = 'active'
  u.groups << groups['HFOSS']
  u.save
end


# Random Users (for a more realistic contacts page)
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
  user = i.users.create(:first_name => first_name,:last_name => last_name,:email => email)

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
  
  user.generate_salt!
  user.generate_crypted_password!('test')
  user.generate_activation_code!
  user.role = i.roles.find_by_name("Normal User")
  user.state = 'active'

  # give them some random groups
  group_count = [0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,8,9,10]
  user.groups = i.groups.sort_by { rand }[0,group_count[rand(group_count.length)]]

  user.save
end


# Default Tags
default_tags = ['gov', 'ngo', 'food', 'volunteers', 'medical', 'supplies', 'power',
                'repair', 'south district', 'east district', 'northeast district',
                'roads', 'weather', 'central district', 'hazard']
tags = default_tags.collect {|name| i.tags.create(:name => name)}


# Incidents to fill with updates
filled_incidents = ['Intimidating Ice Storm', 'Terrible Tornado', 'Maleficent Mudslide',]
filled_incidents.each {|name| i.incidents.create(:name => name)}

# Default Incidents
default_incidents = [ # missing: j,k,o,q,u,x,y,z
  'Appalling Avalanche', 'Bothersome Blizzard', 'Contemptible Cyclone',
  'Dread Drought', 'Evil Earthquake', 'Freak Flood', 'Frightful Famine',
  'Grave Gamma-ray burst', 'Horrendous Heat Wave', 'Harrowing Hurricane',
  'Horrible Hailstorm', 'Loathsome Lahar', 'Malicious Monsoon',
  'Nefarious Nuclear Power Plant Disaster', 'Pernicious Plague',
  'Reprobate Riots', 'Shocking Sandstorm', 'Terrifying Typhoon',
  'Tricky Tsunami', 'Vile Volcano', 'Woeful Wildfire']
default_incidents.sort_by {rand}.each {|name| i.incidents.create(:name => name)}


# Default Updates

# don't automatically timestamp these records, because
# we want to be able to control that manually
#
# for the following records, 'time' is minutes offset from
# the first record, because that's easy to specify manually
ActiveRecord::Base.record_timestamps = false

i.incidents.find_by_name('Terrible Tornado').tap do |incident|
  # add some updates here
end

i.incidents.find_by_name('Maleficent Mudslide').tap do |incident|
  # add some updates here
end

i.incidents.find_by_name('Intimidating Ice Storm').tap do |incident|
  updates = [
    { :title  => "Large storm front approaching",
      :text   => "There is a large storm approaching the city. It is moving in from the " +
                 "southwest, and is expected to reach city limits within the next two " +
                 "hours.",
      :author => :a,
      :groups => ['City Hall', 'Emergency Services'], 
      :tags   => ['weather', 'hazard'],
      :time   => 4
    }, 
    { :title  => "Power to the Eastern and Northeastern Districts out",
      :text   => "We are experiencing a total power outage across all of the Eastern " +
                 "and Northeastern Districts of the City. We are investigating the " +
                 "issue and will try to start repairs as soon as possible, however, " +
                 "the storm is hindering exploration. Monitoring systems indicate that " +
                 "there are power lines down across the city.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power', 'east district', 'northeast district'],
      :time   => 60
    },
    { :title  => "Power to the Southern District is out",
      :text   => "Power issues have spread to the Southern District as well. As with " +
                 "previous problems, we are attempting to investigate the problems and " +
                 "will repair them when the storm abates.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power', 'south district'],
      :time   => 80
    },
    { :title  => "Power lines down across the city",
      :text   => "Power issues across the city are largely the result of downed power " +
                 "lines. We are assessing the damage now and will be sending out repair " +
                 "crews shortly.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall', 'Emergency Services', 'Department of Roads'], 
      :tags   => ['power', 'repair', 'hazard'],
      :time   => 134
    },
    { :title  => "Worst of the storm has passed",
      :text   => "It is now safe to send out repair crews for critical infrastructure. " +
                 "Please have crews report back and post updates and results here in a " +
                 "timely manner.",
      :author => :a,
      :groups => ['City Hall'], 
      :tags   => ['weather', 'repair'],
      :time   => 172
    }, 
    { :title  => "Broken glass covering Main Street",
      :text   => "Glass from storefronts lining main street broke during the storm and is " +
                 "now a hazard. Warning signs need to be put up to prevent accidental " +
                 "injuries and vehicle damage.",
      :author => :c,
      :groups => ['City Hall', 'Department of Roads'], 
      :tags   => ['roads', 'gov', 'central district', 'hazard'],
      :time   => 200,
      :comments => [
        { :author => :d,
          :text   => "Is there a plan to clean this up?",
          :time   => 217
        },
        { :author => :e,
          :text   => "A cleaning crew has been dispatched to remove the glass on the " +
                     "street and sidewalks.",
          :time   => 250
        },
      ]
    }, 
    { :title  => "Sending three crews out to repair downed power lines",
      :text   => "Power line repairs are being initiated. We're starting in the Eastern " +
                 "District, and will move on to the Northeastern and then the Southern " +
                 "Districts after that.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall', 'Department of Roads'], 
      :tags   => ['power', 'repair', 'roads'],
      :time   => 204,
      :comments => [
        { :author => :f,
          :text   => "Has there been any progress on repairs?",
          :time   => 230
        },
        { :author => :b,
          :text   => "We're still working in the Eastern District.",
          :time   => 233
        },
        { :author => :b,
          :text   => "Repairs in the Eastern District are completed. See new update for " +
                     "details. Now moving on to the Northeastern District.",
          :time   => 253
        },
        { :author => :b,
          :text   => "Now beginning repairs in the Southern District.",
          :time   => 260
        },
      ]
    },
    { :title  => "Trees and branches blocking roads throughout the city",
      :text   => "Emergency response groups are reporting difficulty moving through " +
                 "some parts of the city, especially in the Southern District.",
      :author => :c,
      :groups => ['Department of Roads', 'Park Services'], 
      :tags   => ['roads','hazard'],
      :time   => 214,
      :comments => [
        { :author => :e,
          :text   => "Cleanup is progressing in all areas.",
          :time   => 240
        },
        { :author => :e,
          :text   => "Cleanup of all know problem locations is done. Please report" +
                     "any further problems.",
          :time   => 340
        },
      ]
    }, 
    { :title  => "Power lines repaired across the Eastern District",
      :text   => "Repairs on power lines in the Eastern District have been completed. " +
                 "Power is expected to go online within the next half an hour after " +
                 "safety checks have been run." +
                 "\n\n" +
                 "We are proceeding to work on downed lines in the Northeastern district.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall', 'Department of Roads'], 
      :tags   => ['power', 'repair', 'roads'],
      :time   => 249
    },
    { :title  => "Large ice buildup on court building roof",
      :text   => "There is a large amount of ice building up on the court building's roof. " +
                 "The roof had been scheduled to undergo repairs, and so is a hazard. " +
                 "\n\n" +
                 "For now, the building has been evacuated. Emergency ice removal and " +
                 "repairs needs to be initiated as soon as possible.",
      :author => :h,
      :groups => ['City Hall'], 
      :tags   => ['repair', 'hazard'],
      :time   => 250
    }, 
    { :title  => "Several more trees in the Southern District are down",
      :text   => "Trees are preventing emergency and repair vehicles from moving in on " +
                 "the center of the power problems in the Southern District. Please " +
                 "get a crew in to fix this as soon as possible.",
      :author => :c,
      :groups => ['City Hall', 'Department of Roads'], 
      :tags   => ['hazard', 'roads', 'power'],
      :time   => 251
    }, 
    { :title  => "Power restored to the Eastern District",
      :text   => "Please report any problems.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power'],
      :time   => 258,
      :comments => [
        { :author => :g,
          :text   => "We're still having to rely on generator power at the hospital. Are " +
                     "we sure that power is working across the district?",
          :time   => 265
        },
        { :author => :b,
          :text   => "It may be a problem isolated to that building complex. We'll send " +
                     "over a crew to investigate.",
          :time   => 280
        },
        { :author => :a,
          :text   => "Has any progress been made on this?",
          :time   => 340
        },
        { :author => :g,
          :text   => "Our power at the hospital is back up.",
          :time   => 360
        },
      ]
    },
    { :title  => "Power lines repaired on all streets in the Northeastern District",
      :text   => "All power lines in the Northeastern district have been repaired. " +
                 "However, we are still having issues restoring power. We are " +
                 "investigating the situation.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall', 'Department of Roads'], 
      :tags   => ['power', 'repair', 'roads'],
      :time   => 303
    },
    { :title  => "Several trees in the downtown park damaged",
      :text   => "Several trees in the downtown park need to be examined and likely " +
                 "removed. Right now they are a probable hazard and should be cordoned " +
                 "off to prevent accidents.",
      :author => :c,
      :groups => ['Park Services'], 
      :tags   => ['hazard'],
      :time   => 310
    }, 
    { :title  => "Generator problems preventing power restoration " +
                 "in the Northeastern District",
      :text   => "We have isolated the power issues in the Northeastern District to " +
                 "an issue with one of the generators. We are starting repairs now.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power', 'repair'],
      :time   => 320,
      :comments => [
        { :author => :d,
          :text   => "Is there a time estimate for this?",
          :time   => 330
        },
        { :author => :a,
          :text   => "Repairs should take no more than two hours.",
          :time   => 338
        },
        { :author => :a,
          :text   => "Repairs are completed.",
          :time   => 445
        },
      ]
    },
    { :title  => "All power lines in the Southern District repaired",
      :text   => "Power should be restored to the Southern within the next half hour.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall', 'Department of Roads'], 
      :tags   => ['power', 'repair'],
      :time   => 452
    },
    { :title  => "Power restored to the Southern District",
      :text   => "Please report any further problems here.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power'],
      :time   => 470
    },
    { :title  => "Power restored for the Northeastern District",
      :text   => "Generator issues have been resolved; please report any problems.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power'],
      :time   => 500
    },
    { :title  => "Power is now restored to the entire city",
      :text   => "The entire city should have power once again.",
      :author => :b,
      :groups => ['Power Plant', 'City Hall'], 
      :tags   => ['power'],
      :time   => 503
    },
  ]
  # get some random authors
  people = []
  updates.each do |u|
    people << u[:author] if !people.include? u[:author]
    if u[:comments]
      u[:comments].each { |c| people << c[:author] if !people.include? c[:author] }
    end
  end
  rand_users = (4..53).to_a.sort_by {rand}[0,people.size].collect {|index| i.users.find(index)}
  name_mapping = {}
  people.each_with_index { |sym,index| name_mapping[sym] = rand_users[index] }
  updates.each do |u|
    u[:author] = name_mapping[u[:author]]
    if u[:comments]
      u[:comments].each { |c| c[:author] = name_mapping[c[:author]] }
    end
  end
  # make actual updates
  base_time = Time.now - 10.hours
  updates.each do |u|
    up = incident.updates.create(:title => u[:title])
    up.text = u[:text]
    up.user = u[:author]
    up.relevant_groups = u[:groups].collect {|g| i.groups.find_by_name(g)}
    up.tags = u[:tags].collect {|t| i.tags.find_by_name(t)}
    up.created_at = up.updated_at = base_time + u[:time].minutes
    up.save
    if u[:comments]
      u[:comments].each do |c|
        com = up.comments.create(:body => c[:text],:user => c[:author],
                                 :created_at => base_time + c[:time].minutes,
                                 :updated_at => base_time + c[:time].minutes)
      end
    end
    up.save
  end
end

# timestamp all following records
ActiveRecord::Base.record_timestamps = true


# Default Carriers
Carrier.create(:name => 'AT&T', :extension => '@txt.att.net')
Carrier.create(:name => 'Boost', :extension => '@myboostmobile.com')
Carrier.create(:name => 'Cricket', :extension => '@sms.mycricket.com')
Carrier.create(:name => 'Nextel', :extension => '@messaging.nextel.com')
Carrier.create(:name => 'T-Mobile', :extension => '@tmomail.net')
Carrier.create(:name => 'Virgin Mobile', :extension => '@vmobl.com')
Carrier.create(:name => 'Verizon', :extension => '@vtext.com')
Carrier.create(:name => 'Sprint', :extension => '@messaging.sprintpcs.com')
Carrier.create(:name => 'Alltel Wireless', :extension => '@message.alltel.com')

User.all.each do |u|
  u.instance.incidents.each do |i|
    f = Feed.make_my_groups_feed(i)
    f.owner = u
    f.save
  end
end

UpdateObserver.enable!
UserObserver.enable!

