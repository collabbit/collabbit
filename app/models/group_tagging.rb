class GroupTagging < ActiveRecord::Base
  include Authority
  belongs_to :tag
  belongs_to :group
end
