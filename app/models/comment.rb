class Comment < ActiveRecord::Base
  include Authority
  belongs_to :update
  belongs_to :user
end
