require 'pathname'

module Renderish
  # Offers some helper methods. So that I needn't monkey-patch Ruby itself.
  module Utils
    class << self
      # Check a file to see if it's a absolute path.
      # @param [String] file file name
      # @return True if the file is a absolute path, vice versa.
      #
      # @api public
      def absolute_path?(file)
        Pathname(file).absolute?
      end

      # Translate a module to a file name according to its name.
      # @param [Class] klass
      # @return A string represents the file name.
      # @example
      #   Renderish::Utils.module_to_file_name(Foo::BarBaz) #=> "foo/bar_baz"
      #
      # @api public
      def module_to_file_name(klass)
        klass.name.gsub(/::/, '/').
                   gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                   gsub(/([a-z\d])([A-Z])/, '\1_\2').
                   tr("-", "_").
                   downcase
      end

      def restore_instance_variable_after(object, ivar, new_value)
        original_value =
          object.instance_variables.any? { |var| var.to_sym == ivar } &&
          object.instance_variable_get(ivar)

        object.instance_variable_set ivar, new_value
        result = yield new_value
        object.instance_variable_set ivar, original_value
        result
      end
    end
  end
end
