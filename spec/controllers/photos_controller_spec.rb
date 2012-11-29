require 'spec_helper'

describe PhotosController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'add_comment'" do
    it "returns http success" do
      get 'add_comment'
      response.should be_success
    end
  end

end
