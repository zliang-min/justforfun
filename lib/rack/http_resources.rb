require 'rack'

module Rack::HTTPResources

  autoload :BuilderMixin, 'rack/http_resources/builder_mixin'
  autoload :Resource,     'rack/http_resources/resource'
  autoload :Router,       'rack/http_resources/router'

end
