require 'warden'

module Warden::Strategies
  module HTTPAuth
    autoload :Base,     'warden/strategies/http_auth/base'
    autoload :Basic,    'warden/strategies/http_auth/basic'
    autoload :Digest,   'warden/strategies/http_auth/digest'
    autoload :Register, 'warden/strategies/http_auth/register'

    def self.register(&block)
      @register = Register.new
      @register.instance_eval &block
      @register.done!
    end
  end
end
