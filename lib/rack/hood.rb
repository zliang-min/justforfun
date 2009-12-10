module Rack
  class Hood
    # @param [#call] app a rack application
    # @param [Hash] options options to customize the middleware
    # @option [] ???
    def initialize(app, options={})
      @app = app

      Warden::Strategies.add(:basic_http) do
        def valid?
        end

        def authenticate!
        end
      end
    end

    def call(env)
      env['warden'].authenticate! unless env['warden'].authenticate?
    end
  end
end

require 'warden'

module Warden
  module Strategies
    class HTTPAuth::Base < Base

      attr_accessor :realm

      private

      def unauthorized(www_authenticate = challenge)
        return [ 401,
          { 'Content-Type' => 'text/plain',
            'Content-Length' => '0',
            'WWW-Authenticate' => www_authenticate.to_s },
          []
        ]
      end

      def bad_request
        return [ 400,
          { 'Content-Type' => 'text/plain',
            'Content-Length' => '0' },
          []
        ]
      end
    end

    class HTTPAuth::Basic < HTTPAuth::Base
    end
  end
end
