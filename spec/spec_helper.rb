require 'pathname'
TEST_DIR = Pathname(__FILE__).dirname

require 'minitest/autorun'
require 'render-ish'

Dir[TEST_DIR.join('../test/examples/*.rb').to_s].each { |rb| require rb }
