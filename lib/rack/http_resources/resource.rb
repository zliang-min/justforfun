module Rack::HTTPResources::Resource

  include Router

  HTTPObject = Struct.new :request, :response

  attr :http

  def initialize app = nil
    @app = app
  end

  def call env
    dup.call! env
  end

  def call! env
    @env = env
    path = env['REQUEST_PATH']
    if path =~ %r[\A/#{self.class.name.downcase}(/.*)?\Z]
      @http = HTTPObject.new
      http.request = Rack::Request.new env

      body = Rack::Request.instance_methods(false).sort.inject(["<ul>"]) { |a, m|
        a << "<li>#{m} = #{http.request.send m}</li>" rescue a
      }
      body << "</ul>"
      http.response = Rack::Response.new body
      http.response.finish
    else
      [404, {'Content-Type' => 'text/html'}, ["Opps! Not found!"]]
    end
  end

  class << self
    private
    def map_point
      @map ||= %r[\A/#{name.downcase}(/.*)?\Z]
    end

    def map path
      @map = %r[\A/#{path}(/.*)?\Z]
    end

    def route!
    end
  end

end
