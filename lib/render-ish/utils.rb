require 'pathname'

module Renderish
  module Utils
    class << self
      # Check a file to see if it's a absolute path.
      # @param [String] file
      #
      # @api public
      def absolute_path?(file)
        Pathname(file).absolute?
      end

      # Translates a class to a file name according to its name.
      # @param [Class] klass
      #
      # @api public
      def class_to_file_name(klass)
        klass.name.gsub(/::/, '/').
                   gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                   gsub(/([a-z\d])([A-Z])/, '\1_\2').
                   tr("-", "_").
                   downcase
      end
    end
  end
end
