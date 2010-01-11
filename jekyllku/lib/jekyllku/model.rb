module Jekyllku::Model
  autoload :Page, 'model/page'
  autoload :Post, 'model/post'

  class << self
    attr_writer :database

    def database
      @databse ||= ENV['DATABASE_URL'] || "sqlite://#{Jekyllku.app_root}/db/test.rb"
    end

    def connected?
      Sequel::Model.db and true
    rescue
      false
    end

    def connect
      Sequel.connect database unless connected?
    end
  end
end
