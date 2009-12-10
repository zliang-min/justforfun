require 'pathname'
require 'warden'
require Pathname(__FILE__).dirname.join('lib/rack/hood')

map '/go' do
  # use Rack::Leukocyte
  use Rack::Hood
  run Rack::File.new '/usr/local/programms/go/doc'
end
