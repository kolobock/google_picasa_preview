class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_is_login_required
  before_filter :store_location

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  alias :default_redirect_to :redirect_to
  def redirect_to(*args)
    # we need to keep flash messages for the next action if we redirect
    flash.keep
    default_redirect_to *args
  end

  def check_is_login_required
    authorized_denied unless logged_in?
  end

  #status 403
  def authorized_denied
    cleanup_login_information!
    msg = I18n.t(:error403, :scope => "system")
    respond_to do |format|
      format.html { store_location
      flash[:error] = msg
      redirect_to new_session_path
      }
      format.xml { render :text => {'error' => msg}.to_xml(:root => 'errors'), :status => 403 }
      format.json { render :text => {'error' => msg}.to_json, :status => 403 }
    end
    return false
  end

  def store_location
    if request.get?
      if session[:previous_location].present?
        session[:return_to] = session[:previous_location] unless session[:previous_location] == request.fullpath
      else
        session[:return_to] = root_url
      end
      session[:previous_location] = request.fullpath
    end
  rescue
    session[:return_to] = root_url
  end

  def redirect_back_or_default(default, options = {})
    redirect_to((session[:return_to] || default), options)
    session[:return_to] = nil
  end

  private

  def not_found
    respond_with(nil, :status => 404) do |format|
      format.html {
        flash[:error] = I18n.t(:error404, :scope => "system")
        redirect_to(root_path)
      }
      format.xml { render :text => {'error' => 'Resource not found'}.to_xml(:root => 'errors'), :status => 404 }
      format.json { render :text => {'errors' => ['Resource not found']}.to_json, :status => 404 }
    end
  end

  def logged_in?
    session[:user] && session[:token]
  end

  def cleanup_login_information!
    reset_session
    session[:user] = session[:token] = nil
  end

  def set_login_information!(s)
    session[:user] = s.user
    session[:token] = s.token
  end
end
