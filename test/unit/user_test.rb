#unit tests for user
#tests each method of the user model, as well as the creation of a new user

require 'test_helper'
include ActionController::TestCase::Assertions

class UserTest < ActiveSupport::TestCase
  #Test the creation of a new user
  def test_new_user_validation
    #test save with no attributes set
    user = User.new
    assert !user.save, "No attributes set"
    #test save with only username set
    user.username = "Me"
    assert !user.save, "Still no password, shouldn't save"
    #test save with password - should work
    user.password = "pword!"
    assert user.save, "Should save!"
    #test save with un-unique password
    user.username = "T1"
    assert !user.save, "Un-unique username"
  end

  #Test authentication of user
  def test_user_authentication
    #Test when no arguments given
    assert_nil User.authenticate(nil, nil), "Should just return nil"
    #Test when invalid user given
    assert_nil User.authenticate("bob", "bobpw"), "No user named bob!"
    #Test when invalid password given
    assert_nil User.authenticate(users(:testUser_1).username, "notmypassword"), "Wrong password!"
    #Test successful
    assert_equal users(:testUser_1), User.authenticate(users(:testUser_1).username, "pw1"), "Should be ok."
  end

  #Test creation of salt
  def test_create_new_salt
    user = User.new({:password => "me", :username => "me"})
    assert_not_nil user.salt, "Should be able not nil if salt created ok"
  end

  #test returning list of followed users
  def test_return_list_of_followed_users
    #each test either tests the type of object returned or tests that the size of the array is what is expected
    assert_equal 2, users(:testUser_1).return_list_of_followed_users().size, "Should be 2 users followed"
    assert_equal Array, users(:testUser_1).return_list_of_followed_users().class, "Should be an array"
    assert_equal User, users(:testUser_1).return_list_of_followed_users()[0].class, "Should be an User in the element in the array"
    assert_equal 1, users(:testUser_2).return_list_of_followed_users().size, "Should be 1 users followed"
    assert_equal 1, users(:testUser_3).return_list_of_followed_users().size, "Should be 1 user followed"
    assert_equal 0, users(:testUser_4).return_list_of_followed_users().size, "Should be no users followed"
  end

  #test returning list of followed users
  def test_return_list_of_followers
    #each test either tests the type of object returned or tests that the size of the array is what is expected
    assert_equal 0, users(:testUser_1).return_list_of_followers().size, "Should be no users following"
    assert_equal 2, users(:testUser_2).return_list_of_followers().size, "Should be 2 users following"
    assert_equal 0, users(:testUser_4).return_list_of_followers().size, "Should be no users following"
    assert_equal Array, users(:testUser_1).return_list_of_followers().class, "Should be an array"
    assert_equal User, users(:testUser_2).return_list_of_followers()[0].class, "Should be an User in the element in the array"
  end

  #test for method number of followers - should be similar to results above
  def test_number_of_followers
    assert_equal 0, users(:testUser_1).number_of_followers(), "No Followers expected"
    assert_equal 2, users(:testUser_2).number_of_followers(), "2 Followers expected"
  end

  #test for method number of followees - should be similar to results above
  def test_number_of_followees
    assert_equal 1, users(:testUser_3).number_of_followees(), "1 Follower expected"
    assert_equal 1, users(:testUser_2).number_of_followees(), "1 Follower expected"
    assert_equal 2, users(:testUser_1).number_of_followees(), "2 Followers expected"
    assert_equal 0, users(:testUser_4).number_of_followees(), "0 Followers expected"
  end

  #test for returning number of posts
  def test_number_of_posts
    assert_equal 2, users(:testUser_1).number_of_posts(), "1 post expected"
    assert_equal 0, users(:testUser_3).number_of_posts(), "No posts expected"
  end

  #test that we can't delete the last user
  #method will throw an exception if the user being deleted is the last.
  def test_after_destroy
    assert_nothing_raised {users(:testUser_1).destroy}
    assert_nothing_raised {users(:testUser_2).destroy}
    assert_nothing_raised {users(:testUser_3).destroy}
    assert_raise {users(:testUser_4).destroy}
  end

  #test if the user can follow another user and create the relationship
  #method will throw an exception if not possible
  def test_follow_user
    assert_raise {users(:testUser_1).follow_user(users(:testUser2))}
    assert_raise {users(:testUser_1).follow_user(nil)}
    assert_raise {users(:testUser_1).follow_user(users(:testUser1))}
    assert_nothing_raised {users(:testUser_2).follow_user(users(:testUser_1))}
  end

  #test if the user can unfollow another user and destroy the relationship
  #method will throw an exception if not possible
  def test_unfollow_user
    assert_raise {users(:testUser_1).unfollow_user(users(:testUser4))}
    assert_raise {users(:testUser_1).unfollow_user(nil)}
    assert_raise {users(:testUser_1).unfollow_user(users(:testUser1))}
    assert_nothing_raised {users(:testUser_1).unfollow_user(users(:testUser_2))}
  end

  #test if the user can follow another user
  #similar to results above
  def test_can_follow
    assert !users(:testUser_1).can_follow?(users(:testUser_2)), "Already following two"
    assert !users(:testUser_1).can_follow?(users(:testUser_1)), "Can't follow yourself"
    assert users(:testUser_1).can_follow?(users(:testUser_4)), "Can follow 4"
  end

  #test if the user is following another user - negation of can_follow
  #similar to results above
  def test_following
    assert users(:testUser_1).following?(users(:testUser_2)), "Already following two"
    assert users(:testUser_1).following?(users(:testUser_1)), "Can't follow yourself"
    assert !users(:testUser_1).following?(users(:testUser_4)), "Not following 4"
  end

  #test search by username
  #each test checks if the number of results were as expected
  def test_search_by_username
    assert_equal 1, users(:testUser_1).search_by_username("T1").size(), "Only one T1"
    assert_equal 1, users(:testUser_1).search_by_username("t1").size(), "Only one T1 - capitalisation does not matter"
    assert_equal 3, users(:testUser_1).search_by_username("T").size(), "3 Users with T - excl. current user"
    assert_equal 3, users(:testUser_1).search_by_username("").size(), "Blank shows all excl. current user"
    assert_equal 3, users(:testUser_1).search_by_username(nil).size(), "Blank shows all excl. current user"
    assert_equal 0, users(:testUser_1).search_by_username("Bob").size(), "No bob"
    assert_equal 0, users(:testUser_1).search_by_username("T2").size(), "Search should exclude current user"
  end

  #tests routes set up in config/routes
  def test_valid_routing
    assert_routing "users",  {:controller => 'users', :action => 'index'}
    assert_routing "users/1",  {:controller => 'users', :action => 'show', :id => "1"}
    assert_routing "users/1/edit",  {:controller => 'users', :action => 'edit', :id => "1"}
    assert_routing "users/1/follow",  {:controller => 'users', :action => 'follow', :id => "1"}
    assert_routing "users/1/unfollow",  {:controller => 'users', :action => 'unfollow', :id => "1"}
    assert_routing "users/1/posts",  {:controller => 'users', :action => 'user_posts', :id => "1"}
    assert_routing "followers",  {:controller => 'users', :action => 'followers'}
    assert_routing "followees",  {:controller => 'users', :action => 'followees'}
  end

end
