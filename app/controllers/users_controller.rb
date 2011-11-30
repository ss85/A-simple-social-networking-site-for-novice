class UsersController < ApplicationController

  #action to display followers
  def followers
    @followers = @currentUser.return_list_of_followers()
  end
  
  #action to dosplay
  def followees
    @followees = @currentUser.return_list_of_followed_users()
  end

  #action to display all the users posts
  def user_posts
    @user = User.find_by_id(params[:id])
    #check if the user exists! If they don't redirect to the last page
    if @user
      #posts sorted by date descending
      @posts = @user.posts.sort { |p1, p2| p2.created_at <=> p1.created_at}
    else
      redirect_to(session[:last_page]) unless @user
    end
  end

  #action to follow a user
  #if the user is valid, then the follow_user method is called
  #otherwise, an error is displayed
  #the user is then redirected to the last page they were at (more then one page where the user
  #can follow another user)
  def follow
    userToFollow = User.find_by_id(params[:id])
    begin
    if userToFollow
       @currentUser.follow_user(userToFollow)
       flash[:notice] = "#{userToFollow} followed successfully"
    end
    rescue Exception => e
      flash[:notice] = e.message
    end
    redirect_to(session[:last_page])
  end

  #action to unfollow a user
  #if the user is valid, then the unfollow_user method is called
  #otherwise, an error is displayed
  #the user is then redirected to the last page they were at (more then one page where the user
  #can unfollow another user)
  def unfollow
    userToUnFollow = User.find_by_id(params[:id])
    begin
      if userToUnFollow
        @currentUser.unfollow_user(userToUnFollow)
        flash[:notice] = "#{userToUnFollow} unfollowed successfully"
      end
    rescue Exception => e
      flash[:notice] = e.message
    end
    #Do not want to display a blank search page to the user - head to the user index
    if session[:last_page] == search_path
      redirect_to(:action => "index")
    else
      redirect_to(session[:last_page])
    end
  end

#Scaffolding actions
#These actions have been only slightly modified

  # GET /users
  # GET /users.xml
  def index
    #Get all users but the current user
    @users = User.find(:all, :conditions => ["id <> ?", @currentUser.id], :order => :username)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_id(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by_id(params[:id])
    #Redirect to the index if there is no user to edit or the user they are trying to edit is not themselves
    redirect_to(:action => "index") unless !@user.nil? || @user == @currentUser
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        #is the user being created from someone logged in?
        #if so, redirect to the index and display appropriate message
        if !@currentUser.nil?
          flash[:notice] = "User #{@user.username} was created successfully!"
          format.html { redirect_to(:action => 'index') }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
        #if not, then redirect to login with appropriate message
          flash[:notice] = "User #{@user.username} was created successfully! Please log in below"
          format.html {redirect_to(login_url)}
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find_by_id(params[:id])
    if @user == @currentUser #only allow update if it is the current user editting
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = "User #{@user.username} was updated successfully!"
          format.html { redirect_to(:action => 'index') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to(:action => "index")
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  #only allow the current user to destroy their account
  #might change with the addition of user roles
  def destroy
    @user = User.find_by_id(params[:id])
    begin
      @user.destroy if @user == @currentUser
      session[:user_id] = nil
      flash[:notice] = "#{@user} deleted successfully"
    rescue Exception => e
      flash[:notice] = e.message
    end

    respond_to do |format|
      format.html { redirect_to(login_url) }
      format.xml  { head :ok }
    end
  end
end
