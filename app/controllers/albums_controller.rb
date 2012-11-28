class AlbumsController < ApplicationController
  def index
    @client = Picasa::Client.new(session[:user], session[:token])
    @albums = @client.get_albums_list
  end

  def show
    @client = Picasa::Client.new(session[:user], session[:token])
    @photos = @client.get_photos_from_album(params[:id])
  end

  def add_comment
    
  end
end
