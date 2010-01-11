module Ruhl
  module Rails
    module Helper
      def form_authenticity
        {:value => form_authenticity_token, :type => "hidden", :name => "authenticity_token"}
      end  

      def i(type,column)
        model = presentee.class.name.underscore
        { :type => type,
          :id   => "#{model}_#{column}", 
          :name => "#{model}[#{column}]",
          :value => presentee.send(column)
        }
      end
    end
  end
end
