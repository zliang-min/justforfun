require 'tilt'

# Give objects the ability of rendering.
module Renderish
  autoload :Renderable,    'render-ish/renderable'
  autoload :Utils,         'render-ish/utils'

  require 'render-ish/configuration'
  require 'render-ish/exceptions'
end
