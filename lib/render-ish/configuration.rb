require 'singleton'

module Renderish
  class Configuration
    include Singleton

    @items = {}

    class << self
      # Return all configuration items with their default values.
      # @private
      def items; @items.dup end

      # Adds a configuration item.
      # @param [Symbol, String] name the name of the item.
      # @param [optional, Object] default the default value of the item. Defaults nil.
      def add name, default = nil
        # attr_writer :foo
        # def foo
        #   @foo || self.class.items[:foo]
        # end
        name = name.to_sym
        @items[name] = default

        Configuration.class_eval <<-__CODE__, __FILE__, __LINE__ + 1
          attr_writer #{name.inspect}

          def #{name}
            @#{name} || self.class.items[#{name.inspect}]
          end
        __CODE__

        # attr_writer :foo
        # def foo(eval_proc=true)
        #   value = @foo ||
        #     (is_a?(Module) ? Renderish.configuration.foo : self.class.foo(false))
        #   value.is_a?(Proc) and eval_proc ? instance_eval(&value) : value
        # end
        Renderish::Renderable.module_eval <<-__CODE__, __FILE__, __LINE__ + 1
          attr_writer #{name.inspect}
          def #{name}(eval_proc=true)
            value = @#{name} ||
              (is_a?(Module) ? Renderish.configuration.#{name} : self.class.#{name}(false))
            value.is_a?(Proc) && eval_proc ? instance_eval(&value) : value
          end
        __CODE__
      end
    end

    #attr_accessor *OPTIONS_WITH_DEFAULTS.keys

    {
      :template_path     => '.',
      :template_basename => lambda {
        Renderish::Utils.module_to_file_name(
          is_a?(Module) ? self : self.class
        )
      },
      :template_source   => nil,
      :template_engine   => nil,
      :template_format   => nil,
      :render_scope      => lambda { self }
    }.each { |k, v| add k, v }

    # reset configuration items to their default values.
    # @param [#to_sym] name indicates which item is going to be reset. If pass :all here,
    #   all configuration items will be reset. Defaults :all.
    # @return [NilClass] nil
    def reset(name=:all)
      name = name.to_sym
      items = self.class.items
      (name == :all ? items.keys : [name]).each do |item|
        send "#{item}=", items[item]
      end
      nil
    end

    # Register a template implementation by file extension.
    def register(ext, template_class)
      Tilt.register ext, template_class
    end

    module Helper
      # Returns the configuration object or configures it with a block.
      # Built-in configuration items include:
      # * +template_path+:
      # * +template_basename+:
      # * +template+:
      # * +render_scope+:
      # * +render_format+:
      # * +render_engine+:
      # @yieldparam [Renderish::Configuration] configuration the configuration object.
      # @return [Renderish::Configuration] the configuration object.
      # @example
      #   Renderish.configuration #=> #<Renderish::Configuration>
      #
      #   Renderish.configuration do |config|
      #     config.template_path = '...'
      #     config.template_file = '...'
      #     # ...
      #   end
      def configuration
        yield configuration if block_given?
        Configuration.instance
      end
    end
  end

  extend Configuration::Helper
end
