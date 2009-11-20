module Rack::HTTPResource::Resource

  class << self

    def included resouce
      (@resources ||= []) << resouce
    end

  end

end
