require 'sequel'

module Jekyllku::Model
  autoload :Page, 'model/page'
  autoload :Post, 'model/post'

  class << self
    attr_writer :database

    def database
      @databse ||= ENV['DATABASE_URL'] || test_db
    end

    def connected?
      !Sequel::DATABASES.empty?
    end

    def connect
      Sequel.connect database unless connected?
    end

    private
    def test_db
      path = File.join Jekyllku.app_root, 'db'
      unless File.directory?(path)
        require 'fileutils'
        FileUtils.mkdir_p path
      end
      "sqlite://#{path}/test.rb"
    end
  end # singleton methods
end
