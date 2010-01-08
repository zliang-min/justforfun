module Model
  class Base < Sequle::Model
    class << self
      def generate_schema
      end

      private
      def schema &blk
        @schema = blk
      end
    end # class methods
  end # Base
end
