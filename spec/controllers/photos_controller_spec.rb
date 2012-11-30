require 'spec_helper'
require 'controllers_helper'

describe PhotosController do
  stub_picasa_client_and_controller

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', album_id: 1
      response.should be_success
    end

    it "redirects to login" do
      client.stub(:get_photos_from_album).and_raise(Picasa::PicasaAuthorisationRequiredError)
      get 'index', album_id: 1
      response.should redirect_to(controller: :sessions, action: :new)
    end
  end


end
