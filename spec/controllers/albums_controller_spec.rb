require 'spec_helper'
require 'controllers_helper'

describe AlbumsController do
  stub_picasa_client_and_controller

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "redirects to login" do
      client.stub(:get_albums_list).and_raise(Picasa::PicasaAuthorisationRequiredError)
      get 'index'
      response.should redirect_to(controller: :sessions, action: :new)
    end
  end

end
