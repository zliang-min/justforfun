module Rack::HTTPResources::Resource

  def request
    @request ||= Request.new(env)
  end

  def env env = nil
    @env ||= env
    @env
  end

end
