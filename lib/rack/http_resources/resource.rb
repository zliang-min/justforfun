module Rack::HTTPResources::Resource

  RackObject = Struct.new :request, :response

  attr :rack

  def initialize app = nil
    @app = app
  end

  def call env
    path = env['REQUEST_PATH']
    if path =~ %r[\A/#{self.class.name.downcase}(/.*)?\Z]
      #resource = object.respond_to?(:instance) ? object.instance : object.new
      @rack = RackObject.new
      rack.request = Rack::Request.new env

      body = Rack::Request.instance_methods(false).sort.inject(["<ul>"]) { |a, m|
        a << "<li>#{m} = #{rack.request.send m}</li>" rescue a
      }
      body << "</ul>"
      rack.response = Rack::Response.new body
      rack.response.finish
    else
      [404, {'Content-Type' => 'text/html'}, ["Opps! Not found!"]]
    end
  end

  private
  def map path
  end

end
