require 'test_helper'
include ActionController::TestCase::Assertions

class PostTest < ActiveSupport::TestCase

  #test validation of new post
  def test_new_post_validation
    #test save with no attributes - should not save
    post = Post.new
    assert !post.save, "Post shouldn't save - no attributes set"
    #test save with book - should not save
    post.book = Book.new()
    assert !post.save, "Post shouldn't save - no author set on book, location, thoughts, mood and user"
    #test save with book incomplete - should not save with no author
    post.book.author = "Jed"
    assert !post.save, "Post shouldn't save - no title set on book"
    #test save with book complete - should not save as other attributes missing
    post.book.title = "Rails for Dummies"
    assert !post.save, "Post shouldn't save -  still missing location, thoughts, mood and user"
    #test save with mood - still should not save
    post.mood = "Happy"
    assert !post.save, "Post shouldn't save - still missing location, thoughts and user"
    #test save with location - still should not save
    post.location = "Home"
    assert !post.save, "Post shouldn't save - still missing thoughts and user"
    #test save with location - still should not save need user
    post.thoughts = "Good book"
    assert !post.save, "Post shouldn't save - still missing user"
    #test save with user - all attributes filled should save
    post.user = users(:testUser_1)
    assert post.save, "Post should save"
  end

  #test validation of thoughts length
  #thoughts must be 100 characters or less
  def test_thoughts_length_validation
    testPost = posts(:testPost)
    testPost.thoughts = "A" * 101
    assert !testPost.save, "Post shouldn't save, thoughts over 100 characters"
  end

  #test to see if post editable - based on timestamps
  #current value is post can't be editted after one hour
  def test_editable
    testPost = posts(:testPost)
    testPost.created_at = Time.now
    assert testPost.editable?, "Post should be editable"
    testPost.created_at = Time.now - 1.day
    assert !testPost.editable?, "Post should not be editable"
  end

  #test search by author
  #each test checks if the number of results were as expected
  def test_search_by_book_author
    assert_equal 1, Post.search_by_book_author("Jed").size, "Should only be one post"
    assert_equal 2, Post.search_by_book_author("e").size, "Should be two posts"
    assert_equal 2, Post.search_by_book_author("").size, "Blank returns all - Should be two post"
    assert_equal 2, Post.search_by_book_author(nil).size, "Blank returns all - Should be two post"
    assert_equal 0, Post.search_by_book_author("Bob").size, "Blank returns all - Should be two post"
  end

  #test search by title
  #each test checks if the number of results were as expected
  def test_search_by_book_title
    assert_equal 1, Post.search_by_book_title("Testing").size, "One post expected with Testing"
    assert_equal 2, Post.search_by_book_title("Test").size, "Two posts expected with Testing"
    assert_equal 0, Post.search_by_book_title("Life").size, "No posts expected with Life"
    assert_equal 2, Post.search_by_book_title(nil).size, "Blank returns all - Should be two post"
    assert_equal 2, Post.search_by_book_title("").size, "Blank returns all - Should be two post"
  end

  #tests routes set up in config/routes
  def test_valid_routing
    assert_routing "posts",  {:controller => 'posts', :action => 'index'}
    assert_routing "posts/1",  {:controller => 'posts', :action => 'show', :id => "1"}
    assert_routing "posts/1/edit",  {:controller => 'posts', :action => 'edit', :id => "1"}
  end
end
