require 'spec_helper'

describe Renderish::Utils do
  before(:all) { @it = Renderish::Utils }

  describe "absolute_path?" do
    before do
      @p1 = '/absolute/path'
      @p2 = 'relative/path'

      platform = defined?(RUBY_PLATFORM) && RUBY_PLATFORM || PLATFORM
      @p1 = 'c:/abosolute/path' if platform =~ /win|mingw/
    end

    it "should work properly." do
      @it.absolute_path?(@p1).should be_true
      @it.absolute_path?(@p2).should be_false
    end
  end

  describe "module_to_file_name" do
    it "should work properly" do
      @it.module_to_file_name(Object).should eql("object")
      require 'net/http'
      @it.module_to_file_name(Net::HTTPRequest).should eql("net/http_request")
    end
  end
end
