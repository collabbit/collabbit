class Incident < ActiveRecord::Base
  include Authority
  belongs_to :instance
  has_many :updates, :dependent => :destroy
  has_many :feeds, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of   :name, :within => 2..32
  
  attr_accessible :name, :description, :closed
  
  def closed?
    closed_at != nil
  end
  
  def viewable_by?(user)
    instance.viewable_by?(user)
  end
  
  def self.incidents_arr(instance)
    incidents= instance.incidents.find(:all)
    incidents   
  end
  
  def self.export_model(instance)
    incidents = incidents_arr(instance)
    result_incidents = incidents.to_yaml
    result_incidents.gsub!(/\n/,"\r\n")
    result_incidents
  end

  def self.model_arri(dest)
    Incident
    Dir.chdir(dest)
    @incidentfile = Dir.glob(("*"+self.name.pluralize + ".yml").to_s)
    yfincidents = File.open(@incidentfile.to_s) 
    incidents = YAML.load(yfincidents)
    incidents
  end
  
  def self.import_model(instance, dest)
    incidents = self.model_arri(dest)
    incidents.each do |inci|
      instance.incidents.build(:name => "#{inci.name}", 
                                :description => "#{inci.description}")
      instance.save
    end
  end
  
end
