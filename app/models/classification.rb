class Classification < ActiveRecord::Base
  include Authority
  belongs_to :group
  belongs_to :update
end
