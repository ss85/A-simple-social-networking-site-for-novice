#-User Model-
#------------\

#A user model has been created to capture details about each user
#This is necessary so the user can login to our application

#need the following for encryption
require 'digest/sha1'

class User < ActiveRecord::Base
  #constants
  EXTRA_SALT = "extra salty"
  #relationships
  #dependent => delete_all ensures cascade delete
  has_many :posts, :dependent => :delete_all

  #many to many - a user can have many followed_users, found through the follows link
  has_many :follows, :dependent => :delete_all
  has_many :followed_users, :through => :follows

  #validation for new user
  validates_presence_of :username
  validates_uniqueness_of :username

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_not_blank

  #accessor for password (virtual attribute)
  def password
    @password
  end

  #mutator for password (virtual attribute)
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    #set the salt value for the user
    create_new_salt
    #create new hashed password
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  #authentication method - this is how the user will log in
  #returns nil if an invalid login, else returns the user object and sets the session variable
  #so the application knows the user has logged in
  def self.authenticate(username, password)
    #must find the user before we can check the password!
    user = self.find(:first, :conditions => {:username => username})
    if user
        #encrypt the password the user has provided with their own salt
        expected_password = encrypted_password(password, user.salt)
        if user.hashed_password != expected_password
          user = nil
        end
    end
    user
  end

  #Display object nicely
  def to_s
    username
  end

  #method to return a list of the users that the current user is following
  #uses the follows relationship to access each user
  def return_list_of_followed_users
    @followees = []
    #We need to add each user to the array - otherwise we return an array of object Follow
    self.follows.each {|f| @followees << f.followed_user}
    @followees
  end

  #method to return a list of users that are following the current user
  def return_list_of_followers
    @followers = []
    #Find the list of users following the current user by searching the followed_user_id
    #We need to add each user to the array - otherwise we return an array of object Follow
    Follow.find(:all, :conditions => {:follow_user_id => self.id}).each {|f| @followers << f.user}
    @followers
  end

  #returns the number of followers the user has
  def number_of_followers
    return_list_of_followers.size
  end

  #returns the number of users the user is following
  def number_of_followees
    return_list_of_followed_users.size
  end

  #returns the number of posts the user has made
  def number_of_posts
    self.posts.size
  end

  #method to ensure that there is always a user left in the system
  #probably not required given that anyone can create a new user
  #but good to include in case of future additions that add user roles where
  #only administrators can create users
  def after_destroy
    #after the user has been deleted, check how many are left - if zero, raise an error
    #this will cause the transaction to roll back
    if User.count.zero?
      raise "Can't delete the last user!"
    end
  end

  #method to follow a user
  #creates a new follow object using the current user and the user they wish to follow
  def follow_user(follow_user)
    #before we can create the relationship between the two users, we need to check
    #if the user is not already following the other user, or the user is not trying to follow themself
    #if the user is following the other user that means a relationship already exists
    if following?(follow_user) 
      raise "Can't follow yourself or a user you are already following!"
    else
      Follow.create({:user => self, :followed_user => follow_user})
    end
  end

  #method to unfollow a user
  #destroys the relationship between two users
  def unfollow_user(follow_user)
    #before we can destroy the link we must check if the user is already not following the other user
    #or if the user is trying to unfollow themself.
    #if the user can follow the other user then that means no relationship exists
    if can_follow?(follow_user)
      raise "Can't unfollow yourself or a user that you are not already following!"
    else
      followRel = Follow.find(:first, :conditions => {:user_id => self.id, :follow_user_id => follow_user.id})
      followRel.destroy
    end
  end

  #method to determine if a user can follow another user
  def can_follow?(followee)
    !Follow.exists?(["user_id = ? AND follow_user_id = ?", self.id, followee.id]) && self != followee
  end

  #method to determine if a user is already following another user
  #negation of can_follow?
  def following?(user)
    !can_follow?(user)
  end

  #method to search the users by username
  def search_by_username(search_username)
    #will return all values except the current user
    User.find(:all, :conditions => ["username LIKE ? AND username <> ?", "%#{search_username}%", "#{self.username}"])
  end

  private

  #validation method to check if the user has not entered a password
  def password_not_blank
    errors.add(:password, " Missing password") if password.blank?
  end

  #private method to encrypt password
  def self.encrypted_password(password, salt)
    string_to_hash = password + EXTRA_SALT + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  #private method to set the salt of the user
  #uses the object id and a random number
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
