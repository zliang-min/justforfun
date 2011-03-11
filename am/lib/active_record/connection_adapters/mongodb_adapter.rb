# encoding: utf-8
# @author 梁智敏

require 'mongo'

module ActiveRecord
  class Base
    def self.mongodb_connection(options)
      options = options.symbolize_keys
      ConnectionAdapters::MongodbAdapter.new options
    end
  end

  module ConnectionAdapters
    class MongodbAdapter #< AbstractAdapter
      include ActiveSupport::Callbacks

      define_callbacks :checkout, :checkin

      def initialize(options)
      end

      def verify!(*)
        # TODO check if connection is still alive
      end

      def select(sql, name = nil)
        [{:name => 'gimi', :age => 30}, {:name => 'aki', :age => 23}]
      end
    end
  end
end
