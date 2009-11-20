require 'pathname'
require 'rack'

module Rack::HTTPResources

  __DIR__ = Pathname(__FILE__).dirname.expand_path

  {
    :BuilderMixin => 'builder_mixin',
    :Resource    => 'resource'
  }.each { |mod, file|
    autoload mod, __DIR__ + file
  }

  Rack::Builder.class_eval { include Rack::HTTPResources::BuilderMixin }

end
