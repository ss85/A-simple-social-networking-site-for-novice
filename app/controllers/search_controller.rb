class SearchController < ApplicationController
  #action to search for books\posts
  def searchme
        #check if the user has submitted a search term
        if params[:searchTerm]
          #show message explaining that if no search term is entered all results are returned
          flash.now[:notice] = "No search term entered - returning all results" if params[:searchTerm].strip.empty?
          @results = []
          @searchTerm = params[:searchTerm]
          @searchFor = params[:searchFor]
          #Do search depending on what the user has searched for - currently 3 options
          #I know this is a terrible way of doing things
          #Re modelling might include a different action for each search type?
          if @searchFor == "User"
            @results = @currentUser.search_by_username(@searchTerm)
          elsif @searchFor == "Author"
            @results = Post.search_by_book_author(@searchTerm)
          elsif @searchFor == "Title"
            @results = Post.search_by_book_title(@searchTerm)
          else
            flash.now[:notice] = "Invalid search - please try again"
          end
        end
    end
end
