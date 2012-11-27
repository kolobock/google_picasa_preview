module Picasa
  class Session < Base
    attr_accessor :token, :user, :captcha

    def google_login(email, password)
      url = 'https://www.google.com/accounts/ClientLogin'
      source = "KcK-GooglePicasaPreview-1.0.0"
      #TODO: should be picasa service name &service=lh2: ensure that!
      params = 'accountType=HOSTED_OR_GOOGLE' \
        "&Email=#{email}" \
        "&Passwd=#{password}" \
        '&service=lh2' \
        "&source=#{source}"

      response = http_request(:post, url, params)

      if response.code =~ /20[01]/
        self.captcha = nil
        self.user = email
        /Auth=([[:alnum:]_\-]+)\n/ =~ response.body.to_s
        self.token = $1
      else
        self.user = self.token = nil
        errors = response.body.scan(/Error=(.*)/i).flatten.compact
        #TODO: unlock captcha url: https://www.google.com/accounts/DisplayUnlockCaptcha
        self.captcha = true if errors.include?('CaptchaRequired')
        raise Picasa::PicasaLoginError, "The request for login has failed. (#{errors.to_sentence})"
      end
    end
  end
end
