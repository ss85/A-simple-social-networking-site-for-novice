class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followed_user, :class_name => "User", :foreign_key => "follow_user_id"

  #validates_uniqueness_of :user, :scope => :followed_user
end
