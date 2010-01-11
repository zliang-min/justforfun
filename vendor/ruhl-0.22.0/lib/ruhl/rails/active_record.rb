module Ruhl
  module Rails
    module ActiveRecord
      def error_messages?
        !presentee.errors.empty?
      end
  
      def error_messages
        return if presentee.errors.empty?
        presentee.errors.full_messages
      end
  
      def define_paths(model)
        define_action(model, 'show')                      # show_path(@user)
        define_action(model, 'update')                    # update_path(@user)
        define_action(model, 'delete')                    # delete_path(@user)
        define_action("edit_#{model}", 'edit')            # edit_path(@user)
        define_action(model.pluralize, 'index', false)    # index_path
        define_action(model.pluralize, 'create', false)   # create_path
        define_action("new_#{model}", 'new', false)       # new_path
      end
  
      private
  
      def define_action(model, action, use_presentee = true)
        if use_presentee
          self.class.send(:define_method, "#{action}_path") do
            context.send("#{model}_path", presentee)
          end      
          self.class.send(:define_method, "#{action}_url") do
            context.send("#{model}_url", presentee)
          end      
        else
          self.class.send(:define_method, "#{action}_path") do
            context.send("#{model}_path")
          end      
          self.class.send(:define_method, "#{action}_url") do
            context.send("#{model}_url")
          end      
        end
      end
    end
  end
end