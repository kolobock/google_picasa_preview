require 'spec_helper'
require 'controllers_helper'

describe SessionsController do
  stub_picasa_session_and_controller

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "returns http success" do
      post 'create'
      response.should redirect_to('/')
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      delete 'destroy', id: 1
      response.should redirect_to(:new_session)
    end
  end

end
