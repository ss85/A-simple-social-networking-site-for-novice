#-Post model-
#------------\

#A post model has been created to capture information about each post

class Post < ActiveRecord::Base
  #Relationships
  belongs_to :book
  belongs_to :user

  #validation
  validates_presence_of :mood, :location, :thoughts, :user, :book
  validate :check_thoughts_length

  #Nested attributes allows us to declare one nice form to create a book and a post
  #at the same time! Also ensures that the book is created successfully before creating 
  #the post
  accepts_nested_attributes_for :book

  #Constants
  MAX_THOUGHTS_LENGTH = 100
  MINUTES_UNTIL_UNEDITABLE = 60

  #validation method to check if the thoughts attribute has too many characters
  def check_thoughts_length
    errors.add(:thoughts, " must be at most #{MAX_THOUGHTS_LENGTH} characters long") unless !self.thoughts.nil? && self.thoughts.length <= MAX_THOUGHTS_LENGTH
  end

  #Method to display object nicely
  def to_s
    "#{user} Reading #{book}\nMood: #{mood}\nLocation: #{location}\nThoughts:#{thoughts}"
  end

  #Method to check if the post can be editted - based on time the object was created
  def editable?
    ((Time.now - self.created_at ) / 1.minute).round < MINUTES_UNTIL_UNEDITABLE
  end

  #Method to search posts by book author - uses the Book search method
  def self.search_by_book_author(author)
    Post.find(:all, :conditions => {:book_id => Book.search_by_author(author)})
  end

  #Method to search posts by book title - uses the Book search method
  def self.search_by_book_title(title)
    Post.find(:all, :conditions => {:book_id => Book.search_by_title(title)})
  end

end
