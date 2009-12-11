require 'pathname'
lib = Pathname(__FILE__).dirname.join('lib')
unless $:.include?(lib)
  lib = lib.expand_path
  $:.unshift lib unless $:.include?(lib)
end

require 'rack/hood'

map '/doc' do
  # use Rack::Leukocyte
  use Rack::Session::Cookie
  use Rack::Hood do |manager|
    manager.default_strategies :http_digest
    manager.failure_app = -> env { Rack::Response.new('Sorry!').finish }
  end
  run Rack::File.new '/usr/local/programms/go/doc'
end
