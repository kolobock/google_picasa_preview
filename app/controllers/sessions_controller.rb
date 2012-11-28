class SessionsController < ApplicationController
  skip_before_filter :check_is_login_required, only: [:new, :create, :captcha]
  before_filter :find_session, only: [:new, :create, :captcha]

  def new
  end

  def create
    @session.google_login(params[:email], params[:password])
    set_login_information! @session
    flash[:notice] = 'Logged in successfully!'
    redirect_back_or_default root_url
  rescue Picasa::PicasaLoginError => e
    cleanup_login_information!
    flash[:error] = e.message
    render :captcha and return if @session.captcha
    render :new
  end

  def destroy
    cleanup_login_information!
    flash[:notice] = 'Logged out!'
    redirect_to root_url
  end

  def captcha
    @session.reset_captcha!
  end

  private

  def find_session
    @session = Picasa::Session.new(session[:user], session[:token])
  end
end
