require "spec_helper"

describe Picasa::Client do
  subject { Picasa::Client }
  it 'raises PicasaSessionRequired if initialized without a session' do
    expect { subject.new('') }.to raise_error(Picasa::PicasaSessionRequired)
  end

  def default_headers(token)
    {
        "Authorization" => "GoogleLogin auth=#{token}",
        "GData-Version" => "2"
    }
  end

  context 'requests' do
    let(:session) { s = Picasa::Session.new
        s.user  = 'test@gmail.com'
        s.token = 'session_token'
        s.captcha = nil
      s
    }
    let(:mock_response) { mock().as_null_object }

    subject { Picasa::Client.new(session) }

    let(:album_id) { 123 }
    let(:photo_id) { 123 }
    let(:comment)  { 'comment' }
    let(:xm)       { mock().as_null_object }
    context 'status 200' do
      let(:body) { mock().as_null_object }
      before do
        mock_response.stub(code: '200', body: body)
        subject.stub(:http_request).and_return(mock_response)
        subject.stub(:albums_list) { body }
        subject.stub(:photos_list) { body }
        subject.stub(:comments_count) { body }
      end

      describe '#get_albums_list' do
        it 'returns albums hash' do
          subject.get_albums_list.should == body
        end
        it 'sends :get request to albums list url' do
          subject.should_receive(:http_request).with(
              :get,
              "https://picasaweb.google.com/data/feed/api/user/default",
              nil,
              default_headers(subject.session.token)
          ) { mock_response }
          subject.get_albums_list
        end
      end

      describe '#get_photos_from_album' do
        it 'returns photos hash' do
          subject.get_photos_from_album(album_id).should == body
        end
        it 'sends :get request to photos list url' do
          subject.should_receive(:http_request).with(
              :get,
              "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}",
              'max-results=3',
              default_headers(subject.session.token)
          ) { mock_response }
          subject.get_photos_from_album(album_id)
        end
        it 'returns 3 photos as default' do
          subject.should_receive(:http_request).with(any_args(), any_args(),
              'max-results=3', any_args()
          ) { mock_response }
          subject.get_photos_from_album(album_id)
        end
        it 'returns N photos as per limit option' do
          res = 10
          subject.should_receive(:http_request).with(any_args(), any_args(),
              "max-results=#{res}", any_args()
          ) { mock_response }
          subject.get_photos_from_album(album_id, limit: res)
        end
      end

      describe '#get_recent_comments_for_photo' do
        it 'returns comments count' do
          subject.get_recent_comments_for_photo(album_id, photo_id).should == body
        end
        it 'sends :get request to comments list url' do
          subject.should_receive(:http_request).with(
              :get,
              "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}",
              'kind=comment',
              default_headers(subject.session.token)
          ) { mock_response }
          subject.get_recent_comments_for_photo(album_id, photo_id)
        end
      end

      describe '#add_comment_to_photo' do
        before do
          Builder::XmlMarkup.stub(:new).and_return(xm)
          xm.stub(:entry)    { xm }
          xm.stub(:content)  { xm }
          xm.stub(:category) { xm }
        end
        it 'returns nil if success' do
          subject.add_comment_to_photo(album_id, photo_id, comment).should be_nil
        end
        it 'sends :post request to add the comment url' do
          subject.should_receive(:http_request).with(
              :post,
              "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}",
              "",
              default_headers(subject.session.token).merge("Content-Type"  => "application/atom+xml")
          ) { mock_response }
          subject.add_comment_to_photo(album_id, photo_id, comment)
        end
      end
    end

    context 'status 403' do
      let(:error) { 'Unauthenticated' }
      before do
        mock_response.stub(code: '403', body: "Error=#{error}")
        subject.stub(:http_request).and_return(mock_response)
      end

      describe '#get_albums_list' do
        it 'raises PicasaAuthorisationRequiredError' do
          expect { subject.get_albums_list }.to raise_error(Picasa::PicasaAuthorisationRequiredError)
        end
        it 'explains an error' do
          expect { subject.get_albums_list }.to raise_error(/The request for get albums list has failed. \(#{error}\)/)
        end
      end

      describe '#get_photos_from_album' do
        it 'raises PicasaAuthorisationRequiredError' do
          expect { subject.get_photos_from_album(album_id) }.to raise_error(Picasa::PicasaAuthorisationRequiredError)
        end
        it 'explains an error' do
          expect { subject.get_photos_from_album(album_id) }.to raise_error(/The request for get photos has failed. \(#{error}\)/)
        end
      end

      describe '#get_recent_comments_for_photo' do
        it 'raises PicasaAuthorisationRequiredError' do
          expect { subject.get_recent_comments_for_photo(album_id, photo_id) }.to raise_error(Picasa::PicasaAuthorisationRequiredError)
        end
        it 'explains an error' do
          expect { subject.get_recent_comments_for_photo(album_id, photo_id) }.to raise_error(/The request for get comment of photo has failed. \(#{error}\)/)
        end
      end

      describe '#add_comment_to_photo' do
        it 'raises PicasaAuthorisationRequiredError' do
          expect { subject.add_comment_to_photo(album_id, photo_id, comment) }.to raise_error(Picasa::PicasaAuthorisationRequiredError)
        end
        it 'explains an error' do
          expect { subject.add_comment_to_photo(album_id, photo_id, comment) }.to raise_error(/The request for add a comment has failed. \(#{error}\)/)
        end
      end
    end
  end
end
