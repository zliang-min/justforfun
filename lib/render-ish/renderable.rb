module Renderish
  module Renderable

    def self.included(mod)
      mod.extend ClassMethods
      mod.extend self
    end

    module ClassMethods
      def template_helpers
        @template_helpers ||= Module.new
      end

      def template_helper *args
        args.each { |mod| @template_helpers.send :include, mod }
      end
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
    #   @option [Symbol] :format specify the document format. In actual fact, it has nothing to do with the document format, but just change the way how it looks for the template file to be rendered. See example.
    #   @option [#to_s] :engine specify which template engine is going to be used. If the engine is not registered, UnsupportedEngine error will be raised. This option also will change the way how the template file will be found.
    #   @option [Object] :scope indicates in which context the template is rendered.
    #     Defaults +render_scope+.
    #   @option [String] :source if this option is specified, then no template files are used, but just render this source string. __NOTE__: this option should be used together with :engine option.
    # @example
    #   class Thing
    #     include Renderish
    #   end
    #
    #   Thing.new.render :type   => :html #=> may render file thing.html.erb
    #   Thing.new.render :engine => :haml #=> render file thing.haml
    def render(*args)
      options  = extract_render_options! args

      engine   = options[:engine] ? Tilt[options[:engine]] : Tilt
      raise UnsupportedEngine.new(options[:engine]) unless engine

      scope    = options[:scope].dup
      class << scope; self; end.send :include, self.class.template_helpers

      template =
        if source = options[:source]
          fail "You have specified template source without template engine." if engine == Tilt
          engine.new { source }
        else
          engine.new(pick_template(args.first, options))
        end

      if layout = options[:layout]
        layout = pick_layout layout, options

        content = {}
        scope.instance_variable_set :@renderish_content_for_layout, content
        content[:layout] = template.render(scope)

        Tilt.new(layout).render scope, do |*args|
          content[args.first || :layout]
        end
      else
        template.render scope
      end
    end

    private
      # @private
      def extract_render_options! args
        options = args.last.is_a?(Hash) ? args.pop : {}
        options[:source] ||= template_source
        options[:format] ||= template_format
        options[:engine] ||= template_engine
        options[:scope]  ||= render_scope
        options
      end

      # @private
      def find_template(name, options={})
        if File.exists?(name) && Tilt[name]
          name
        else
          name = File.join template_path, name unless Utils.absolute_path?(name)
          name = name + ".#{options[:format]}" if options[:format]

          if engine = options[:engine]
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
