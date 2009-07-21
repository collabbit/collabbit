#Linking the default data together
g1 = Group.find(1)
g2 = Group.find(2)
g3 = Group.find(3)

u1 = User.find(1)
u2 = User.find(2)

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

up1 = Update.find(1)
up2 = Update.find(2)
up3 = Update.find(3)
up4 = Update.find(4)
up5 = Update.find(5)
up6 = Update.find(6)

t1 = Tag.find(1)
t2 = Tag.find(2)
t3 = Tag.find(3)
t4 = Tag.find(4)
t5 = Tag.find(5)
t6 = Tag.find(6)

up1.relevant_groups << Group.find(1)
up1.relevant_groups << Group.find(2)
up2.relevant_groups << Group.find(1)
up2.relevant_groups << Group.find(2)
up2.relevant_groups << Group.find(3)
up3.relevant_groups << Group.find(2)
up3.relevant_groups << Group.find(1)
up4.relevant_groups << Group.find(2)
up4.relevant_groups << Group.find(3)
up5.relevant_groups << Group.find(1)
up6.relevant_groups << Group.find(2)
up6.relevant_groups << Group.find(3)

up1.issuing_group = Group.find(1)
up4.issuing_group = Group.find(2)

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