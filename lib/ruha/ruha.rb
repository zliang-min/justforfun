dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'ruha/version'

# The module that contains everything Ruha-related:
#
# * {Ruha::Engine} is the class used to render Ruha within Ruby code.
# * {Ruha::Helpers} contains Ruby helpers available within Ruha templates.
# * {Ruha::Template} interfaces with web frameworks (Rails in particular).
# * {Ruha::Error} is raised when Ruha encounters an error.
# * {Ruha::HTML} handles conversion of HTML to Ruha.
#
# Also see the {file:HAML_REFERENCE.md full Ruha reference}.
module Ruha
  extend Ruha::Version

  # A string representing the version of Ruha.
  # A more fine-grained representation is available from Ruha.version.
  VERSION = version[:string] unless defined?(Ruha::VERSION)
end

require 'ruha/util'
require 'ruha/engine'
