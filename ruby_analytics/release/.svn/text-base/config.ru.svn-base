require ::File.join(::File.dirname(__FILE__), 'init')
require ::File.join(::File.dirname(__FILE__), 'lib/ruby_analytics')

use Rack::ShowExceptions unless RubyAnalytics.production_mode?
use Rack::Sendfile

map '/' do
  if RubyAnalytics.production_mode?
    run RubyAnalytics.new(:logger_level => ::Logger::ERROR, :logger_path => RubyAnalytics.root.join('log/production.log'))
  else
    use Rack::Reloader
    run RubyAnalytics.new(:logger_level => ::Logger::DEBUG)
  end
end

unless RubyAnalytics.production_mode?
  map '/test' do
    run Rack::File.new(RubyAnalytics.root.join('test').to_s)
  end

  map '/compress.html' do
    run lambda {
      require 'erb'
      Rack::Response.new(ERB.new(::File.read(RubyAnalytics.root.join('lib/compress.html.erb'))).result).finish
    }
  end
end
