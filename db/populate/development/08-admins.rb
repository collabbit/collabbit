#Default Admins
a = Admin.create_or_update(:id => 1, :email => 'blabla@bla.bla')
b = Admin.create_or_update(:id => 2, :email => 'blahblah@blah.blah')

a.salt = Digest::SHA1.hexdigest('bla')
a.crypted_password = a.generate_crypted_password('sahana123')
a.save
b.salt = Digest::SHA1.hexdigest('blah')
b.crypted_password = b.generate_crypted_password('sahana123')
b.save