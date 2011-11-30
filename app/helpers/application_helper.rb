#These methods are those required for the standard layout, as well as some used in multiple
#views.  They have been included here to reduce code re-use and to allow the view code to be
#as clean as possible

module ApplicationHelper
#method to display navigation bar to the user
#checks if the user is logged in, and displays the appropriate options
  def control_panel_helper
    if @currentUser
      "<li>|</li>
       <li>#{link_to 'New Post', new_post_path, :id => "navigation"}</li>
       <li>#{link_to 'My Posts', user_posts_path(@currentUser)}</li>
       <li>|</li>
       <li>#{link_to 'All Users', users_path, :id => "navigation"}</li>
       <li>#{link_to 'My Followers', followers_path, :id => "navigation"}</li>
       <li>#{link_to 'My Followees', followees_path, :id => "navigation"}</li>
       <li>#{link_to 'My Settings', edit_user_path(@currentUser), :id => "navigation"}</li>
       <li>|</li>
       <li>#{link_to 'Search', search_path()}</li>
      <li>|</li>"
    else
      "<li>#{link_to 'New User', new_user_path}</li>"
    end
  end

  #Method to return a link to login or out, depending on if the current user is logged in
  def login_or_out_helper
    if @currentUser
      "<li>#{link_to 'Logout', logout_path, :id => "navigation"}</li>"
    else
      "<li>#{link_to 'Login!', login_path, :id => "navigation"}</li>"
    end
  end

  #method to return a link to view the users posts if the current user is following them
  def user_posts_helper(user)
    if @currentUser.following?(user) || @currentUser == user
      link_to user.username, user_posts_path(user.id)
    else
      user.username
    end
  end

  #method to determine if the user can follow or unfollow another user
  def follow_helper(user)
    #Dont return link for the current user
    if user != @currentUser
      if @currentUser.can_follow?(user)
        link_to "&nbsp;Follow&nbsp;", follow_url(:id => user.id)
      else
        link_to "Unfollow",  unfollow_url(:id => user.id)
      end
    end
  end

  #method to display current user if logged in
  def display_current_user
    if @currentUser
      "<p class=\"currentUser\">Currently logged in as #{@currentUser}</p>"
    end
  end

end
