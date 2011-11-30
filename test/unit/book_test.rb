require 'test_helper'

class BookTest < ActiveSupport::TestCase
  #test validation of new book
  def test_new_book_validation
    #test save with no attributes - should not save
    book = Book.new
    assert !book.save, "No attributes set, should not save"
    #test save with author - should not save
    book.author = "Jed"
    assert !book.save, "No title set, should not save"
    #test save with title - should save
    book.title = "Life of Jed"
    assert book.save, "Should save ok"
    #test save with blank author- should not save
    book.author = ""
    assert !book.save, "Blank author, should not save"
    #test save with blank title - should not save
    book.title = ""
    book.author = "Jed"
    assert !book.save, "Blank title, should not save"
  end

  #test search by author
  #each test checks if the number of results were as expected
  def test_search_by_author
    assert_equal 1, Book.search_by_author("Jed").size, "1 Book listed by Jed"
    assert_equal 2, Book.search_by_author("e").size, "2 Books listed by with an e in the author"
    assert_equal 3, Book.search_by_author("").size, "Blank returns all 3 books"
    assert_equal 3, Book.search_by_author(nil).size, "Blank returns all 3 books"
    assert_equal 0, Book.search_by_author("J.R.R Tolkien").size, "No Tolkien books expected"
  end

  #test search by title
  #each test checks if the number of results were as expected
  def test_search_by_title
    assert_equal 1, Book.search_by_title("Life of bob").size, "1 Book listed with title Life of bob"
    assert_equal 1, Book.search_by_title("LiFe oF bOB").size, "1 Book listed with title LiFe oF bOB - capitalisation does not matter"
    assert_equal 2, Book.search_by_title("Test").size, "2 Books listed by with a test in the title"
    assert_equal 3, Book.search_by_title("").size, "Blank returns all 3 books"
    assert_equal 3, Book.search_by_title(nil).size, "Blank returns all 3 books"
    assert_equal 0, Book.search_by_title("The Hobbit").size, "No Tolkien books expected"
  end

end
