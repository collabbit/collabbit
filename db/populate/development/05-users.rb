UserObserver.disable!

# Default Users
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
john.save

jane.salt = Digest::SHA1.hexdigest('2')
jane.crypted_password = jane.generate_crypted_password('sahana123')
jane.save

joey.salt = Digest::SHA1.hexdigest '1'
joey.crypted_password = joey.generate_crypted_password('sahana123')
joey.save

UserObserver.enable!