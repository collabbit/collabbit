class Comment < ActiveRecord::Base
  include Authority
  acts_as_archive
  belongs_to :update
  belongs_to :user
  
  validates_presence_of :body
  validates_length_of :body, :within => 2..4096
end
