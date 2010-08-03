class Tagging < ActiveRecord::Base
  include Authority
  
  belongs_to :tag
  belongs_to :update
  
end
