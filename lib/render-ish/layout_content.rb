module Renderish
  class LayoutContent

    def initialize
      @contents = {}
    end

    # Append content to the specific name.
    # @param [optional, #to_s] name the name of content. It's +layout+ when it's omitted.
    # @param [String] content
    def append(*args)
      content = args.pop
      name = args.first || 'layout'
      (@contents[name.to_s] ||= "") << content
    end

    # Retrieve content by its name.
    # @param [optional, #to_s] name the name of conent. It's +layout+ when it's omitted.
    # @return [String] content under the name.
    def [](name)
      @contents[name.to_s]
    end

    # @private
    def to_proc
      lambda { |*args|
        @content[(args.first || 'layout').to_s]
      }
    end

  end
end
