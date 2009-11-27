require 'singleton'

module Renderish
  class Configuration
    include Singleton

    OPTIONS_WITH_DEFAULTS = {
      :template_path => '.',
      :template_file => nil
    }

    attr_accessor *OPTIONS_WITH_DEFAULTS.keys

    def initialize
    end

    module Helper
      def configuration
        yield configuration if block_given?
        Configuration.instance
      end
    end
  end
end
