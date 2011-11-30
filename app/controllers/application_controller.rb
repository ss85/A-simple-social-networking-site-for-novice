# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #Set standard layout for all pages
  layout "standard"
  
  #Things to do before filtering
  before_filter :authorise, :except => :login
  before_filter :find_current_user
  after_filter :set_last_page_session_var
  

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected

  #method to set the currentUser variable used by multiple controllers
  #better to call and set once then multiple times
  def find_current_user
     @currentUser = User.find_by_id(session[:user_id])
  end

  #set the variable for the last page the user has visited
  #used to direct the user to the last page they were at in some cases
  def set_last_page_session_var
    session[:last_page] = request.request_uri
  end

  #method to ensure the user is authorised
  #redirects the user to the login page if the user cannot be found using the session var
  #one exception - the new user method and create method can be called without logging in
  def authorise
    unless User.find_by_id(session[:user_id]) || (self.controller_name == 'users' && (self.action_name == 'new' || self.action_name == 'create'))
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please login!"
      redirect_to login_url
    end
  end
end
