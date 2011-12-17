# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8406dc20b6131ea8a90ec68109f869b1'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  # before_filter :get_tag_cloud

  # 访问了acl9控制的资源而没有权限时引发这个异常，在此捕获处理
  rescue_from 'Acl9::AccessDenied', :with => :access_denied
  rescue_from 'ActiveRecord::RecordNotFound',:with => :record_not_found
  rescue_from 'ActionController::MethodNotAllowed',:with => :record_not_found

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  def get_tag_cloud
	  @tag_cloud = Video.tag_counts
	end

private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # acl9访问控制不通过时
  def access_denied
    if current_user
      render :template => 'shared/access_denied'
    else
      flash[:notice] = '你没有登陆或者没有权限执行此操作。'
      redirect_to login_path
    end
  end

  def record_not_found
    # render :template => 'shared/404'
    flash[:notice] = '没有这个东西'
    redirect_to '/'
  end

end
