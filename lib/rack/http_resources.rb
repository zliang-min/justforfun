require 'pathname'
require 'rack'

module Rack::HTTPResources

  __DIR__ = Pathname(__FILE__).dirname.expand_path.join('http_resources')

  {
    :BuilderMixin => 'builder_mixin',
    :Resource    => 'resource'
  }.each { |mod, file|
    autoload mod, __DIR__.join(file).to_path
  }

end

Rack::Builder.class_eval { include Rack::HTTPResources::BuilderMixin }
