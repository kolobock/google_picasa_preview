class CommentsController < ApplicationController
  before_filter :init_picasa_client, :find_album, :find_photo

  def index
    @comments = @client.get_recent_comments_for_photo(@album, @photo)
    respond_to do |format|
      format.html { render partial: 'comments', locals: {comments: @comments} }
    end
  rescue
    render text: 'No comments'
  end

  def create
    @comment = params[:message]
    @client.add_comment_to_photo(@album, @photo, @comment)
    redirect_to :index
  rescue
    render text: 'Comment was not added.'
  end

  private

  def find_album
    @album = params[:album_id]
  end

  def find_photo
    @photo = params[:photo_id]
  end
end
