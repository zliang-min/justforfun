require 'rack/auth/basic'

module Warden
  module Strategies
    class HTTPAuth::Basic < HTTPAuth::Base

      def authenticate!
        auth = Rack::Auth::Basic::Request.new(env)

        return custom!(unauthorized) unless auth.provided?
        return fail!(:bad_request) unless auth.basic?

        if _valid?(auth)
          env['REMOTE_USER'] = auth.username
          success! auth.username
        end

        fail!
      end

      private

      def challenge
        'Basic realm="%s"' % realm
      end

      def _valid?(auth)
        auth!(*auth.credentials)
      end

    end
  end
end
