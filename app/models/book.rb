#-Book model-
#------------\

#A separate model for a Book has been created to allow for future development
#If this application were developed further, it is expected that a book could have other fields
#including ISBN number, link to a thumbnail, publisher year etc
#Furthermore, users can be reading the same book - although no suitable method of removing duplicates
#was found (see attached report for details), it is expected that only books that are unique would be stored

class Book < ActiveRecord::Base
  validates_presence_of :author, :title
  #validates_uniqueness_of :author, :scope => :title, :message => " and title must be unique!"
  #would like to include this validation but creates problems when making a new post
  has_many :posts

  #Method to display object nicely
  def to_s
    "\"" + title + "\" by " + author
  end

  #Method to search for a book by title
  #takes in a string parameter and finds any book that has the phrase passed in in its title field
  def self.search_by_title(search_title)
    Book.find(:all, :conditions => ["title LIKE ?", "%#{search_title}%"])
  end

  #Method to search for a book by author
  #takes in a string parameter and finds any book that has the phrase passed in in its author field
  def self.search_by_author(search_author)
    Book.find(:all, :conditions => ["author LIKE ?", "%#{search_author}%"])
  end

end
