# Default Updates
UpdateObserver.disable!
Update.create_or_update(:id => 1, :title => 'First Update! YAY',
                        :text => 'We have it all under control... nbd...',
                        :user_id => 1, :incident_id => 1, :group_id => 1)
                        
Update.create_or_update(:id => 2, :title => 'Nevermind!',
                        :text => "I guess we don't really have it under control.. sowwy...",
                        :user_id => 1, :incident_id => 1, :group_id => 1)
                        
Update.create_or_update(:id => 3, :title => 'Cost update',
                        :text => 'The cost of this incident has now exceeded one billion gagillion fafillion... yen',
                        :user_id => 2, :incident_id => 2)
                        
Update.create_or_update(:id => 4, :title => 'MOAR Volunteers!',
                        :text => 'We have a dire need for volunteers on this incident!',
                        :user_id => 2, :incident_id => 1)
                        
Update.create_or_update(:id => 5, :title => 'Animals problem', :text => 'Lots of animals need shelter!',
                        :user_id => 1, :incident_id => 1, :group_id => 3)
                        
Update.create_or_update(:id => 6, :title => 'Food needed!',
                        :text => 'We need more food to distribute! Please help!',
                        :user_id => 2, :incident_id => 1, :group_id => 2)
                        
UpdateObserver.enable!