require 'pathname'
require Pathname(__FILE__).dirname.join('../warden/strategies/http_auth')

module Rack
  class Hood
    # @param [#call] app a rack application
    # @param [Hash] options options to customize the middleware
    # @option [] ???
    def initialize(app, options={}, &block)
      Warden::Strategies::HTTPAuth.register do
        digest do
          def realm; 'gimi' end

          def auth!(username)#, password)
            #username == 'gimi.liang' and password == 'abc'
            'abc'
          end
        end
      end

      config = options
      @warden_manager = Warden::Manager.new(Filter.new(app), config, &block)
    end

    def call(env)
      @warden_manager.call(env)
    end

    class Filter
      def initialize(app)
        @app = app
      end

      def call(env)
        env['warden'].authenticate! unless env['warden'].authenticated?
        @app.call(env)
      end
    end
  end
end
