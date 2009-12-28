#Default Instances
i = Instance.create_or_update(:id => 1, :short_name => 'demo', :long_name => 'Demo Instance')
i.roles = Role.default_setup
i.save