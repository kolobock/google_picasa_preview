require "spec_helper"

describe Picasa::Client do
  subject { Picasa::Client }
  it 'raises PicasaSessionRequired if initialized without a session'

  describe '#get_albums_list' do
    it 'raises PicasaAuthorisationRequiredError'
    it 'explains an error'
    it 'returns albums hash'
    it 'sends :get request to albums list url'
  end

  describe '#get_photos_from_album' do
    it 'raises PicasaAuthorisationRequiredError'
    it 'explains an error'
    it 'returns photos hash'
    it 'sends :get request to photos list url'
  end

  describe '#get_recent_comments_for_photo' do
    it 'raises PicasaAuthorisationRequiredError'
    it 'explains an error'
    it 'returns comments count'
    it 'sends :get request to comments list url'
  end

  describe '#add_comment_to_photo' do
    it 'raises PicasaAuthorisationRequiredError'
    it 'explains an error'
    it 'returns nil if success'
    it 'sends :post request to add the comment url'
  end
end
