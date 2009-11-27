require 'tilt'
# Give objects the ability of rendering.
module Renderish

  autoload :Configuration, 'render-ish/configuration'

  extend Configuration::Helper

  def self.included mod
    mod.extend ClassMethods
  end

  module ClassMethods
    def template_path
      @template_path ||
        look_up_method_in_superclasses(:template_path) ||
        Renderish.template_path
    end

    def template_path= path
      @template_path = path
    end

    def template_file
      @template_file ||
        Renderish.template_file || (
          @default_template_file ||=
          name.gsub(/::/, '/').
               gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
               gsub(/([a-z\d])([A-Z])/,'\1_\2').
               tr("-", "_").
               downcase
        )
    end

    def template_file= file
      @template_file = file
    end

    private
      def look_up_method_in_superclasses name
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

  def render_scope scope = nil
    if scope
      @render_scope = scope
    else
      @render_scope || default_render_scope
    end
  end

  def template_path
    @template_path || self.class.template_path
  end

  def template_path= path
    @template_path = path
  end

  def template_file
    @template_file || self.class.template_file
  end

  def template_file= file
    @template_file = file
  end

  def look_up_template format = nil
    basename = File.join template_path, template_file
    basename << ".#{format}" if format
    ext =
      Tilt.mappings.keys.find { |ext|
        File.exists? basename + ".#{ext}"
      }
    basename + ".#{ext}"
  end

  def render format = nil
    Tilt.new(look_up_template(format)).render render_scope
  end

end
