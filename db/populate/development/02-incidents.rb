#Default Incidents
Incident.create_or_update(:id => 1, :name => 'Hurricane Luis', :description => 'Something Happened. Uh oh!', :instance_id => 1)
Incident.create_or_update(:id => 2, :name => 'Hurricane James', :description => 'Something Happened. Oh no!', :instance_id => 1)
Incident.create_or_update(:id => 3, :name => 'Earthquake Alice', :description => 'OMG!', :instance_id => 2)
Incident.create_or_update(:id => 4, :name => 'Volcano Bob', :description => 'Lava everywhere!', :instance_id => 2)