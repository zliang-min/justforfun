module Renderish
  module Renderable

    def self.included(mod)
      mod.extend self
    end

    # Render the object.
    # @overload render(options)
    #   equals +render(nil, options)+
    # @overload render(template, options)
    #   @param [Symbol, String, #to_s] template decides which template is going to be rendered.
    #     When this parameter is +nil+, it renders the template defined by method +template_basename+;
    #     When it's a +Symbol+, it renders template "#{template_path}/#{template_basename}/#{template}";
    #     When it's a +String+, it's treated as the name of the template file. If it's a relative
    #       path, it will be looked for in the +template_path+;
    #     Otherwise, its +to_s+ method will be called and treated as a String.
    #   @param [Hash] options options to customize render behavior
    #   @option [String, Symbol, Boolean, #to_s] :layout indicates which template is going to be
    #     rendered as layout.
    #     When this parameter is +false+ no layout is used. This is the default behavior. You can
    #       change this in your class or Renderish.configuration;
    #     When it's +true+ the default layout is used, which is "#{template_path}/layout/#{template_basename}";
    #     When it's a +Symbol+ the following layout is used: "#{template_path}/layout/#{layout}";
    #     When it's a +String+ it'll be treated as the template file name. If it's a relative path
    #       it will be looked for in the +template_path+;
    #     Otherwise, its +to_s+ method will be called and treated as a String.
    #   @option [Symbol] :type specify the document type. In actual fact, it has nothing to do with the document type. This option just change the way how it look for the file to be rendered. See example.
    #   @option [#to_s] :engine specify which template engine is going to be used. If the engine is not registered, UnsupportedEngine error will be raised. This option also will change the way how the template file will be found.
    #   @option [Object] :scope indicates in which context the template is rendered.
    #     Defaults +render_scope+.
    # @example
    #   class Thing
    #     include Renderish
    #   end
    #
    #   Thing.new.render :type   => :html #=> may render file thing.html.erb
    #   Thing.new.render :engine => :haml #=> render file thing.haml
    def render(*args)
      options  = args.last.is_a?(Hash) ? args.pop : {}
      scope    = options[:scope] || render_scope
      template = pick_template args.first, options

      if layout = options[:layout]
        layout = pick_layout layout, options

        Utils.restore_instance_variable_after(scope, :@_content_for_layout, {}) do |content|
          content[:layout] = Tilt.new(template).render(scope)

          Tilt.new(layout).render scope, do |*args|
            content[args.first || :layout]
          end
        end
      else
        Tilt.new(template).render scope
      end
    end

    private
      # @private
      def find_template(name, options={})
        if File.exists?(name) && Tilt[name]
          name
        else
          name = File.join template_path, name unless Utils.absolute_path?(name)
          name = name + ".#{options[:type]}" if options[:type]

          if engine = options[:engine] && options[:engine].to_s
            raise UnsupportedEngine.new(engine) unless Tilt.mappings.has_key?(engine)
            template_file = name + ".#{engine}"
            raise NoTemplateError.new(template_file, options) unless
              File.exists?(template_file)
          else
            ext =
              Tilt.mappings.keys.find { |ext|
                File.exists? name + ".#{ext}"
              }
            raise NoTemplateError.new(name + ".[#{Tilt.mappings.keys.join('|')}]", options) \
              unless ext
            template_file = name + ".#{ext}"
          end

          template_file
        end
      end

      # @private
      def pick_layout(layout, options={})
        layout =
          case layout
          when TrueClass
            "layout/#{template_basename}"
          when Symbol
            "layout/#{layout}"
          when String
            layout
          else
            layout.to_s # something like Pathname
          end

        find_template layout, options
      end

      # @private
      def pick_template(name=nil, options={})
        name =
          case name
          when NilClass
            template_basename
          when Symbol
            File.join template_basename, name
          when String
            name
          else
            name.to_s # something like Pathname
          end

        find_template name, options
      end
  end
end
