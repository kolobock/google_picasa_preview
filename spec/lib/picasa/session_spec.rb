require 'spec_helper'

describe Picasa::Session do
  subject { Picasa::Session.new }
  let(:user)     { 'user@google.com' }
  let(:password) { 'UserGooglePassword' }

  describe '#google_login' do
    let(:mock_response) { mock().as_null_object }
    let(:token) { 'UIOhfkasjdhfksdfoIUOI_-adskljfaldsjf-_wetriohgfjh34546trwgfsgk-_lsdfl' }

    it 'expects two arguments' do
      expect { subject.google_login(user) }.to raise_error(ArgumentError)
    end

    context 'response code 403' do
      let(:error) { 'Unauthenticated' }
      before do
        mock_response.stub(:code) { 403 }
        mock_response.stub(:body) { "Error=#{error}" }
        subject.stub(:http_request).and_return(mock_response)
        subject.user  = user
        subject.token = token
      end

      it 'raises with PicasaLoginError' do
        expect { subject.google_login(user, password) }.to raise_error(Picasa::PicasaLoginError)
      end
      it 'explains error' do
        expect { subject.google_login(user, password) }.to raise_error(/The request for login has failed. \(#{error}\)/)
      end
      it 'nullifies user and token' do
        subject.should_receive(:user=).with(nil)
        subject.should_receive(:token=).with(nil)
        subject.should_not_receive(:captcha=).with(true)
        expect { subject.google_login(user, password) }.to raise_error
      end
      context 'captcha request from Google' do
        let(:error) { 'CaptchaRequired' }
        before do
          mock_response.stub(:body) { "Error=#{error}" }
          subject.stub(:http_request).and_return(mock_response)
        end
        it 'sets captcha=true' do
          subject.should_receive(:captcha=).with(true)
          expect { subject.google_login(user, password) }.to raise_error
        end
      end
    end

    context 'response code 20[01]' do
      before do
        mock_response.stub(:code) { '200' }
        mock_response.stub(:body) { "Auth=#{token}\n" }
        subject.stub(:http_request).and_return(mock_response)
        subject.user  = nil
        subject.token = nil
      end
      after do
        subject.google_login(user, password)
      end
      it 'sets user to email' do
        subject.should_receive(:user=).with(user)
      end
      it 'sets token to Auth token' do
        subject.should_receive(:token=).with(token)
      end
      it 'nullifies captcha' do
        subject.should_receive(:captcha=).with(nil)
      end
    end

    context 'http_request' do
      let(:url) { 'https://www.google.com/accounts/ClientLogin' }
      let(:source) { "KcK-GooglePicasaPreview-1.0.0" }
      let(:params) {
          'accountType=HOSTED_OR_GOOGLE' \
          "&Email=#{user}" \
          "&Passwd=#{password}" \
          '&service=lh2' \
          "&source=#{source}"
      }
      before do
        mock_response.stub(:code) { '200' }
        mock_response.stub(:body) { "Auth=#{token}\n" }
      end
      after do
        subject.google_login(user, password)
      end
      it { subject.should_receive(:http_request).with(:post, url, params) { mock_response } }
    end
  end
end
