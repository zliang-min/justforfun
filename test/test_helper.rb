require 'pathname'
TEST_DIR = Pathname(__FILE__).dirname

require 'riot'
require 'render-ish'

Dir[TEST_DIR.join('examples/*.rb').to_s].each { |rb| require rb }
