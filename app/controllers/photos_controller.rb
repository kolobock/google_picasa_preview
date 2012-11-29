class PhotosController < ApplicationController
  before_filter :init_picasa_client, :find_album

  def index
    @photos = @client.get_photos_from_album(@album)
  end

  def add_comment
    @photo = params[:photo_id]
    @comment  = params[:comment]
    @client.add_comment_to_photo @album, @photo, @comment
    @comment_count = @client.get_recent_comments_for_photo(@album, @photo)
  end

  private

  def find_album
    @album = params[:album_id]
  end
end
