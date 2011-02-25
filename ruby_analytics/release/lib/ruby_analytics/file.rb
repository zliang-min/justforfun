require 'rack'

class RubyAnalytics
  class File < Rack::File
    attr_reader :file_filter

    def initialize(root, options={})
      super root
      
      @file_filter =
        if options[:except]
          (except = [options[:except]]).flatten!
          lambda { |file| not except.any? { |pattern| pattern === file } }
        elsif options[:only]
          (only = [options[:only]]).flatten!
          lambda { |file| only.any? { |pattern| pattern === file } }
        else
          lambda { |file| true }
        end
    end

    def _call(env)
      @path_info = Rack::Utils.unescape(env["PATH_INFO"])
      return forbidden if @path_info.include? ".."
      return not_found unless servable?(@path_info) # or forbidden?

      @path = F.join(@root, @path_info)

      begin
        if F.file?(@path) && F.readable?(@path)
          serving
        else
          raise Errno::EPERM
        end
      rescue SystemCallError
        not_found
      end
    end

    private
      def servable?(file)
        @file_filter.call file[1..-1] # PATH_INFO, if non-empty, must start with **/**
      end
  end # File
end
