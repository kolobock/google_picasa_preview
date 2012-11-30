class PhotosController < ApplicationController
  before_filter :init_picasa_client, :find_album

  def index
    @photos = @client.get_photos_from_album(@album)
    respond_to do |format|
      format.html { render partial: 'photos', locals: {photos: @photos} }
    end
  end

  private

  def find_album
    @album = params[:album_id]
  end
end
