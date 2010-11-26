class Membership < ActiveRecord::Base
  include Authority
  belongs_to :group
  belongs_to :user
  
  owned_by :user
  
  #validates_associated :group
  #validates_associated :user
  
  validates_uniqueness_of :user_id, :scope => :group_id
  
  def chair?
    is_chair
  end
  
  def self.memberships_arr(instance)
    users = User.users_arr(instance)
    mem_array = Array.new
      users.each do |us|
        memberships = us.memberships.find(:all)
        mem_array += memberships
    end
    mem_array
  end
  
  def self.export_model(instance)
    mem_array = memberships_arr(instance)
    result_memberships = mem_array.to_yaml
    result_memberships.gsub!(/\n/,"\r\n")
    result_memberships
  end
  
  def self.model_arri(dest)
    Membership
    Dir.chdir(dest)
    memfile = Dir.glob("*"+self.name.pluralize + ".yml")
    yfmems = File.open(memfile.to_s)
    memships = YAML.load(yfmems)
    memships
end

def self.import_model(instance, dest)
  memships = model_arri(dest)
  groups = Group.model_arri(dest)
  grouptypes = GroupType.model_arri(dest)
  users = User.model_arri(dest)
  memships.each do |mems|
      ct = -1
      users.each do |user|
        ct+=1
        break if mems.user_id == user.id
      end
    
      cnt = -1
      groups.each do |group|
        cnt+=1
        break if mems.group_id == group.id
      end
      
      count = -1
      grouptypes.each do |gtype|
        count += 1
        break if gtype.id == groups[cnt].group_type_id
      end
      
    user = instance.users.find_by_email(users[ct].email.to_s)
    grouptype = instance.group_types.find_by_name(grouptypes[count].name.to_s)
    grp = grouptype.groups.find_by_name(groups[cnt].name.to_s)
    memship = user.memberships.build(:group_id => "#{grp.id}")
    user.save
    end
end
  
end
