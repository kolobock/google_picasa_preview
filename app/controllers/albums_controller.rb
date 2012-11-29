class AlbumsController < ApplicationController
  before_filter :init_picasa_client

  def index
    @albums = @client.get_albums_list
  end
end
