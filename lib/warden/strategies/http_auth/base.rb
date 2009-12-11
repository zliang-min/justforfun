module Warden
  module Strategies
    class HTTPAuth::Base < Base

      def valid?
        respond_to?(:realm) and respond_to?(:auth!)
      end

      private

      def unauthorized(www_authenticate = challenge)
        [
          401,
          {
            'Content-Type' => 'text/plain',
            'Content-Length' => '0',
            'WWW-Authenticate' => www_authenticate.to_s
          },
          []
        ]
      end
    end
  end
end
