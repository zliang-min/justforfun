require 'pathname'
require 'tilt'
# Give objects the ability of rendering.
module Renderish

  class NoTemplateError < RuntimeError
    def initialize(object, options={})
      super "No supported templates were found for #{object.inspect}, with options #{options.inspect}"
    end
  end

  class UnsupportedEngine < RuntimeError
    def initialize(engine)
      super "Engine #{engine} is not supported."
    end
  end

  autoload :Configuration, 'render-ish/configuration'
  autoload :Utils,         'render-ish/utils'

  extend Configuration::Helper

  def self.included(mod)
    mod.extend ClassMethods
  end

  module ClassMethods
    def template_path
      @template_path ||
        look_up_method_in_superclasses(:template_path) ||
        Renderish.template_path
    end

    def template_path=(path)
      @template_path = path
    end

    def template_file
      @template_file ||
        Renderish.template_file ||
          (@default_template_file ||= Utils.class_to_file_name(self))
    end

    def template_file=(file)
      @template_file = file
    end

    private
      def look_up_method_in_superclasses(name)
        # make method like a inheritable class veriable
        sc = superclass
        while sc.respond_to?(name)
          if value = sc.send(name)
            break value
          end
          sc = sc.superclass
        end
      end
  end

  extend ClassMethods
  
  def self.template_path
    @template_path ||= '.'
  end

  def self.template_file
    @template_file
  end

  def default_render_scope
    self
  end

  def render_scope(scope=nil)
    if scope
      @render_scope = scope
    else
      @render_scope || default_render_scope
    end
  end

  def template_path
    @template_path || self.class.template_path
  end

  def template_path=(path)
    @template_path = path
  end

  def template_file
    @template_file || self.class.template_file
  end

  def template_file=(file)
    @template_file = file
  end

  def find_template(file, options={})
    if File.exists?(file) && Tilt[file]
      file
    else
      file = File.join template_path, file unless Utils.absolute_path?(file)
      file = file + ".#{options[:type]}" if options[:type]

      if engine = options[:engine] && options[:engine].to_s
        raise UnsupportedEngine, engine unless Tilt.mappings.has_key?(engine)
        template_file = file + ".#{engine}"
        raise NoTemplateError, self.class, options unless
          File.exists?(template_file)
      else
        ext =
          Tilt.mappings.keys.find { |ext|
            File.exists? basename + ".#{ext}"
          }
        raise NoTemplateError, self.class, options unless ext
        template_file = basename + ".#{ext}"
      end

      template_file
    end
  end

  def pick_layout(layout, options={})
    layout =
      case layout
      when TrueClass
        "layout/#{Utils.class_to_file_name self}"
      when Symbol
        "layout/#{layout}"
      when String
        layout
      else
        pick_layout layout.to_s, options # something like Pathname
      end

    find_template layout, options
  end

  def pick_template file = nil
  end

  # @param [Hash] options options to customize render behavior
  # @option [String, Symbol, Boolean, ~to_s] :layout
  # @option [Symbol] :type specify the document type. In actual fact, it has nothing to do with the document type. This option just change the way how it look for the file to be rendered. See example.
  # @engine [~to_s] :engine specify which template engine is going to be used. If the engine is not registered, UnsupportedEngine error will be raised. This option also will change the way how the template file will be found.
  # @example
  #   class Thing
  #     include Renderish
  #   end
  #
  #   Thing.new.render :type   => :html #=> may render file thing.html.erb
  #   Thing.new.render :engine => :haml #=> render file thing.haml
  def render(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    template = pick_template args.first
    basename = File.join template_path, template_file
    if layout = options[:layout]
      layout = pick_layout layout, options
    end
    Tilt.new(find_template(options)).render render_scope
  end

end
