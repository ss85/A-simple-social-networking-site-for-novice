class AdminController < ApplicationController
  #action to allow the user to login!
  def login
    #if the user is already logged in, redirect them to home
    redirect_to(posts_url) if @currentUser
    #if the user has posted a request
    if request.post?
      #originally had a method to allow user to be created without authentication if there
      #were no current users stored in the db
      #however with the new user method available to all this is no longer required
      user = User.authenticate(params[:username], params[:password])
      if user
        uri = session[:original_uri]
        session[:original_uri] = nil
        #set session var for user
        session[:user_id] = user.id
        #redirect to the original uri the user was trying to reach, or just go home if they went straight to login
        redirect_to(uri || {:controller => "posts", :action =>  "index"})
      else
        flash.now[:notice] = "Invalid login"
      end
    end
  end

  #destroy session variables and redirect to login
  def logout
    session[:user_id] = nil
    redirect_to(:action => "login")
  end

end
