module Warden::Strategies
  module HTTPAuth
    # A helper class that helps people add the http authentication strategies to Warden.
    class Register
      EMPTY_BLOCK = lambda {}.freeze

      [:basic, :digest].each do |method|
        class_eval <<-_CODE_, __FILE__, __LINE__ + 1
        # @overload #{method}(name, &block)
        # @overload #{method}(mod)
        # @overload #{method}(name, mod)
        def #{method}(*args, &block)
          @use_#{method} = true
          name, mod = args
          name, mod = mod, name if mod.nil? and name.is_a?(Module)
          @#{method}_name = name || :http_#{method}
          @#{method}_block = mod ? lambda { include mod } : (block || EMPTY_BLOCK)
        end
        _CODE_
      end

      def done!
        Warden::Strategies.add @basic_name, Basic, &@basic_block if @use_basic
        Warden::Strategies.add @digest_name, Digest::MD5, &@digest_block if @use_digest
      end
    end
  end
end
