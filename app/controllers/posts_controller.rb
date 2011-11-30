class PostsController < ApplicationController

#No custom actions
#Only a few changes to each method, such as ensuring the current user is the one updating\deleting the post
#and editting the index method to return all friends posts
  # GET /posts
  # GET /posts.xml
  def index
    #required a new post variable so we can post on the index page
    @post = Post.new
    @post.build_book
    @posts = Post.find(:all, :conditions => {:user_id => [@currentUser].concat(@currentUser.return_list_of_followed_users)}, \
                        :order => "created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new
    @post.build_book
    #build_book builds the nested attribute book
    puts @post.user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find_by_id(params[:id])
    #ensure the post is editable, the post exists and the current user is the one editting
    redirect_to (posts_url) unless @post && @post.user == @currentUser && @post.editable?
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.user = @currentUser
    respond_to do |format|
      if @post.save
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    #only allow updates if the update is allowed
    if @post && @post.user == @currentUser && @post.editable?
      respond_to do |format|
        if @post.update_attributes(params[:post])
          format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy if @post.user == @currentUser

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
end
