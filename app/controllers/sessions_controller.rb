class SessionsController < ApplicationController
  skip_before_filter :check_is_login_required, only: [:new, :create, :captcha]
  before_filter :find_session, only: [:new, :create, :destroy]

  def new
  end

  def create
    @session.google_login(params[:email], params[:password])
    set_login_information! @session
    flash[:notice] = 'Logged in successfully!'
    redirect_back_or_default
  rescue Picasa::PicasaLoginError => e
    render :captcha and return if @session.captcha
    cleanup_login_information!
    flash.now[:error] = e.message
    render :new
  end

  def destroy
    cleanup_login_information!
    flash[:notice] = 'Logged out!'
    redirect_to new_session_url
  end

  def captcha
    render text: 'There is no need to reset captcha yet' and return unless @session
    @session.reset_captcha!
  end

  private

  def find_session
    @session = Picasa::Session.new(session[:user], session[:token])
  end
end
