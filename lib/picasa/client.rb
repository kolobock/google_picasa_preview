module Picasa
  class Client < Base
    attr_accessor :session

    def initialize(session)
      raise Picasa::PicasaSessionRequired, "Picasa Client requires valid session" unless session.is_a?(Picasa::Session)
      self.session = session
    end

    # retrieves albums from picasa
    # https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#ListAlbums
    def get_albums_list
      url = "https://picasaweb.google.com/data/feed/api/user/default"

      response = http_request(:get, url, nil, default_headers)

      if response.code =~ /20[01]/
        albums_list response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get albums list has failed. (#{scan_body_for_errors(response.body).to_sentence})"
      end
    end

    # retrieves photos from the specific album
    # https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#ListPhotos
    # limiting number of photos with max-results param
    # https://developers.google.com/picasa-web/docs/2.0/reference#Parameters
    def get_photos_from_album(album_id, options={limit: 3})
      url = "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}"
      params = "max-results=#{options[:limit]}"

      response = http_request(:get, url, params, default_headers)

      if response.code =~ /20[01]/
        photos_list response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get photos has failed. (#{scan_body_for_errors(response.body).to_sentence})"
      end
    end

    # retrieves comments for photo and returns their count only (we don't need to show the comments as per original task description)
    # https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#ListComments
    def get_recent_comments_for_photo(album_id, photo_id)
      url = "https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}"
      params = 'kind=comment'

      response = http_request(:get, url, params, default_headers)

      if response.code =~ /20[01]/
        comments_count response.body
      else
        raise Picasa::PicasaAuthorisationRequiredError, "The request for get comment of photo has failed. (#{scan_body_for_errors(response.body).to_sentence})"
      end
    end

    require 'builder'
    # adds a coomment ot a photo
    # https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#AddComments
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

      response = http_request(:post, url, params, default_headers.merge(headers))

      raise Picasa::PicasaAuthorisationRequiredError, "The request for add a comment has failed. (#{scan_body_for_errors(response.body).to_sentence})" unless response.code =~ /20[01]/
    end

    private

    def default_headers
      # https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#Versioning
      {
        "Authorization" => "GoogleLogin auth=#{self.session.token}",
        "GData-Version" => "2"
      }
    end
  end
end
