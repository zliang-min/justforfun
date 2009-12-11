module Warden::Strategies
  module HTTPAuth
    module Digest
      autoload :MD5, 'warden/strategies/http_auth/digest/md5'
    end
  end
end
