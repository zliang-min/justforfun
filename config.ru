require 'pathname'
require 'rack/http_resources'

if ENV['RACK_ENV'] != 'production'
  use Rack::Reloader, 0
  use Rack::CommonLogger
  use Rack::ShowExceptions
  use Rack::Lint
end

set :app_root, Pathname(__FILE__).dirname.expand_path
set :resources_path, 'resources'

resources Posts
