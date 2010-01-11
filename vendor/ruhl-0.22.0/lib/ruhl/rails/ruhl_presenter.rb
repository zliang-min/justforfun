require 'ruhl/rails/active_record'
require 'ruhl/rails/helper'

module Ruhl
  module Rails
    class Presenter
      include Ruhl::Rails::ActiveRecord
      include Ruhl::Rails::Helper
  
      attr_reader :presentee, :context
  
      def initialize(context, obj = nil)
        @context = context

        # May only want to use the form helper
        if obj
          @presentee = obj
          define_paths(obj.class.name.underscore.downcase)
        end
      end
    
      def method_missing(name, *args)
        if presentee.respond_to?(name)
          # Pass presenter method call to model so you don't have to
          # redefine every model method in the presenter class.
          presentee.send(name, *args)
        elsif context.respond_to?(name)
          # Instead of saying context.link_to('Some site', some_path)
          # can just use link_to
          context.send(name, *args)
        end
      end

      # Extend scope of respond_to? to model.
      def respond_to?(name)  
        if super
          true
        else
          presentee.respond_to?(name)
        end
      end  
    end
  end
end

module ActionController
  class Base    

    protected

    def present(action_sym = action_name, object = nil)
      object_sym = object || controller_name.singularize

      render  :template => "#{controller_name}/#{action_sym}", 
        :locals => {:object => presenter_for(object_sym) }    
    end

    def presenter_for(object)

      if object.is_a?(Symbol) || object.is_a?(String)
        # Set instance variable if it exists
        if instance_variables.include?("@#{object}")
          obj = instance_variable_get("@#{object}")
        end
        name = object.to_s.camelize
      else
        name = object.class.name.camelize
        obj = object
      end

      Object.const_get("#{name}Presenter").new(@template, obj)
    end

    helper_method :presenter_for   
  end
end
