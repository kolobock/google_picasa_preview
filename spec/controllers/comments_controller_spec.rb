require 'spec_helper'
require 'controllers_helper'

describe CommentsController do
  stub_picasa_client_and_controller

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', album_id: 1, photo_id: 1
      response.should be_success
    end

    it "render 'No comments'" do
      client.stub(:get_recent_comments_for_photo).and_raise(Picasa::PicasaAuthorisationRequiredError)
      get 'index', album_id: 1, photo_id: 1
      response.should render_template(text: 'No comments')
    end
  end

  describe "POST 'create'" do
    it "returns http success" do
      post 'create', album_id: 1, photo_id: 1, comment: 'comment'
      response.should redirect_to(action: :index)
    end

    it "render 'No comments'" do
      client.stub(:add_comment_to_photo).and_raise(Picasa::PicasaAuthorisationRequiredError)
      post 'create', album_id: 1, photo_id: 1, comment: 'comment'
      response.should render_template(text: 'Comment was not added.')
    end
  end

end
