module Picasa
  class Client < Base
    attr_accessor :session

    def initialize(session)
      raise Picasa::PicasaSessionRequired, "Picasa Client requires valid session" unless session.is_a?(Picasa::Session)
      self.session = session
    end

    def get_albums_list
      url = "https://picasaweb.google.com/data/feed/api/user/default"

      response = http_request(:get, url, nil, default_header)

      if response.code =~ /20[01]/
        albums_list response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get albums list has failed. (#{response.body})"
      end
    end

    def get_photos_from_album(album_id)
      url = "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}"

      response = http_request(:get, url, nil, default_header)

      if response.code =~ /20[01]/
        photos_list response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get photos has failed. (#{response.body})"
      end
    end

    def get_recent_comments_for_photo(album_id, photo_id)
      url = "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}"
      params = 'kind=comment'

      response = http_request(:get, url, params, default_header)

      if response.code =~ /20[01]/
        comments_count response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get comment of photo has failed. (#{response.body})"
      end
    end

    require 'builder'
    def add_comment_to_photo(album_id, photo_id, comment)
      url = "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}"
      headers = { "Content-Type"  => "application/atom+xml" }
      params = ''

      xm = Builder::XmlMarkup.new(:target => params, :indent => 2)
      xm.entry(:xmlns => 'http://www.w3.org/2005/Atom') do
        xm.content(comment)
        xm.category(
            :scheme => "http://schemas.google.com/g/2005#kind",
            :term   => "http://schemas.google.com/photos/2007#comment"
        )
      end

      response = http_request(:post, url, params, default_header.merge(headers))

      raise Picasa::PicasaAuthorisationRequiredError, "The request for add a comment has failed. (#{response.body})" unless response.code =~ /20[01]/
    end

    private

    def default_header
      {"Authorization" => "GoogleLogin auth=#{self.session.token}"}
    end
  end
end
