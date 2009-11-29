require 'micronaut'

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

Micronaut.configure do |c|
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
end

require 'render-ish'
require 'pathname'

FIXTURES_DIR = Pathname(__FILE__).dirname.join 'fixtures'
Dir[FIXTURES_DIR.join('*.rb').to_s].each { |rb| require rb }
