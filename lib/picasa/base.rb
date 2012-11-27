require 'net/https'
require 'xmlsimple'

module Picasa
  class Base
    protected

    def http_request(method, url, params=nil, headers=nil)
      uri = URI.parse(url)

      request             = Net::HTTP.new(uri.host, uri.port)
      request.use_ssl     = true
      request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      case method
        when :get
          request.get("#{uri.path}?#{params}", headers)
        when :post
          request.post(uri.path, params, headers)
        else
          raise PicasaUnknownHTTPRequest, 'Unknown request type. :get and :post are allowed only.'
      end
    end

    def self.entries(xml_response)
      xml = XmlSimple.xml_in(xml_response, 'ForceArray' => false)
      res = xml['totalResults'].to_i
      return [] if res == 0

      entries = (res > 1 ? xml["entry"] : [xml["entry"]])
      entries.compact
    end

    def albums_list(xml_albums)
      self.class.entries(xml_albums).inject([]) do |albums, album|
        albums << {
            album_id:         album['id'].last,
            title:            album['title']['content'],
            summary:          album['summary']['content'],
            name:             album['name'],
            numphotos:        album['numphotos'].to_i,
            photo:            album['group']['content']['url'],
            photo_thumbnail:  album['group']['thumbnail']['url']
          }
      end
    end

    def photos_list(xml_photos, options = {limit: 3})
      limit = options.delete(:limit).to_i
      self.class.entries(xml_photos).inject([]) do |photos, photo|
        photos << {
            photo_id:   photo['id'].last,
            title:      (photo['group']['description']['content'] || photo['group']['title']['content']),
            thumbnail:  photo['group']['thumbnail'].second['url'],
            photo:      photo['content']['src']
          }
        return photos unless photos.count < limit
        photos
      end
    end

    def comments_count(xml_comments)
      self.class.entries(xml_comments).count
    end
  end

  ### Errors
  class PicasaLoginError < StandardError; end
  class PicasaUnknownHTTPRequest < StandardError; end
  class PicasaSessionRequired < StandardError; end
  class PicasaAuthorisationRequiredError < StandardError; end
end
