def stub_picasa_client_and_controller

  let(:client) { mock().as_null_object }
  before do
    controller.stub(:init_picasa_client)      { true }
    controller.stub(:check_is_login_required) { true }
    controller.stub(:store_location) { true }
    controller.instance_variable_set(:@client, client)
  end

end

def stub_picasa_session_and_controller

  let(:session) { mock().as_null_object }
  before do
    controller.stub(:find_session)      { true }
    controller.stub(:store_location) { true }
    controller.instance_variable_set(:@session, session)
  end

end