module PostsHelper
  #method to return a link to edit the current post if the post is editable
  def edit_post_helper(post)
    link_to 'Edit', edit_post_path(post) if @currentUser == post.user && post.editable?
  end

  #method to return a link to delete the post if the post belongs to the current user
  def delete_post_helper(post)
    link_to 'Destroy', post, :confirm => 'Are you sure you want to delete your post?', :method => :delete if @currentUser == post.user
  end

end
