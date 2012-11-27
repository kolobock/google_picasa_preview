require 'net/https'

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
  end

  ### Errors
  class PicasaLoginError < StandardError; end
  class PicasaUnknownHTTPRequest < StandardError; end
end
