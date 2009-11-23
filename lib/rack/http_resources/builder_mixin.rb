require 'ostruct'

module Rack::HTTPResources::BuilderMixin

  class Options < OpenStruct
    def []=(key, value) self.send "#{key}=", value end
  end

  def resources object
    object.module_eval {
      include Rack::HTTPResources::Resource
    } unless object.ancestors.include?(Rack::HTTPResources::Resource)

    map "/#{object.to_s.downcase}" do
      run -> env {
        path = env['PATH_INFO'].gsub(/^\/|\/$/, '')
        action = path.empty? ? 'index' : path

        resource = object.respond_to?(:instance) ? object.instance : object.new

        resource.env env
        response = Response.new

        response.write resource.respond_to?(:public_send) ?
          resource.public_send(action) :
          resource.__send__(action)

        response['Content-Type'] = 'text/html'
        response.finish
      }
    end
  end

  def set key, value = nil
    if key.is_a?(Hash)
      key.each { |k, v| set k, v }
    else
      options[key] = value
    end
  end

  def options
    @options ||= Options.new
  end

end
