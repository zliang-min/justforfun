require 'gem'
require 'jekyllku'

# Since Jekyllku::App is not thing more than a standard sinatra app, you can customize it in the way with which you have already got familious.
# Jekyllku::App.use Rack::CommonLogger
# Jekyllku::App.use Race::Cache
# Jekyllku::App.set :some_option, :some_value
# Jekyllku::App.enable :some_flag
#
# Or you can customize your app with options, e.g.
# run Jekyllku::App.new(:key => :value, :flag => true, :middlewares => [Rack::CommonLogger, Rack::Cache])
run Jekyllku::App.new
