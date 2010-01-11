module Ruhl
  class Engine
    NBSP = (//.respond_to?(:encoding) ? /\u{00a0}/ : /\302\240/).freeze

    attr_reader :layout, :layout_source, :local_object, :block_object
    attr_reader :document, :scope, :current_tag, :call_result, :ruhl_actions

    def initialize(html, options = {})
      @local_object   = options[:local_object] || options[:object]
      @block_object   = options[:block_object]
      @layout_source  = options[:layout_source]

      if @layout = options[:layout]
        raise LayoutNotFoundError.new(@layout) unless File.exists?(@layout)
      end

      if @layout || @local_object || @block_object
        @document = Nokogiri::HTML.fragment(html)
      else
        @document = Nokogiri::HTML(html)
        @document.encoding = Ruhl.encoding
      end

    end

    def render(current_scope)
      set_scope(current_scope)

      parse_doc(document)

      if @layout
        render_with_layout 
      else
        document.to_s.gsub(NBSP, ' ')
      end
    end

    # The _render_ method is used within a layout to inject
    # the results of the template render.
    #
    # Ruhl::Engine.new(html, :layout => path_to_layout).render(self)
    def _render_
      document.to_s
    end

    private

    def render_with_layout
      render_nodes Nokogiri::HTML( @layout_source || File.read(@layout) )
    end

    def render_partial
      unless File.exists?(call_result)
        raise PartialNotFoundError.new(call_result) 
      end

      render_nodes Nokogiri::HTML.fragment( File.read(call_result) )
    end

    def render_collection
      actions = ruhl_actions.join(",").to_s.strip if ruhl_actions

      current_tag['data-ruhl'] = actions if actions.length > 0
      html = current_tag.to_html
      
      new_content = call_result.collect do |item|
        
        if actions.length == 0 && current_tag.xpath('.//*[@data-ruhl]').length == 0
          if item.is_a?(Hash)
            t = current_tag.dup
            apply_hash(t, item)
            t.to_html
          else
            current_tag.inner_html = item.to_s
            current_tag.to_html
          end
        else
          Ruhl::Engine.new(html, :local_object => item).render(scope)
        end

      end.to_s

      current_tag.swap(new_content)
    end

    def render_block
      Ruhl::Engine.new(current_tag.inner_html, 
                        :block_object => call_result).render(scope)
    end

    def render_nodes(nodes)
      parse_doc(nodes)
      nodes.to_s
    end

    def parse_doc(doc)
      if (nodes = doc.xpath('*[@data-ruhl][1]')).empty?
        nodes = doc.search('*[@data-ruhl]')
      end

      return if nodes.empty?

      @current_tag = nodes.first

      @ruhl_actions = current_tag.remove_attribute('data-ruhl').value.split(',')

      process_attribute

      parse_doc(doc)
    end

    def process_attribute
      catch(:done) do
        ruhl_actions.dup.each_with_index do |action, ndx|
          # Remove action from being applied twice.
          ruhl_actions.delete_at(ndx)

          process_action(action)
        end
      end
    end

    def process_action(action)
      attribute, value = action.split(':')

      code = (value || attribute)
      @call_result = execute_ruby(code.strip)

      if value.nil?
        process_results
      else
        if attribute =~ /^_/
          send("ruhl#{attribute}")
        else
          current_tag[attribute] = call_result.to_s
        end
      end
    end

    def ruhl_use_if
      ruhl_if {ruhl_use } 
    end

    def ruhl_use
      if call_result.kind_of?(Array)
        render_collection
        throw :done
      else
        current_tag.inner_html = render_block
      end
    end

    alias_method :ruhl_collection, :ruhl_use
     
    def ruhl_if
      if stop_processing?
        current_tag.remove
        throw :done
      else
        if continue_processing?
          # yield if block given. otherwise do nothing and have ruhl
          # continue processing
          yield if block_given?
        else
          if block_given?
            yield
          else
            process_results
          end
        end
      end
    end

    def ruhl_unless
      if call_result
        unless call_result_empty_array?
          current_tag.remove
          throw :done
        end
      end
    end

    def ruhl_partial
      current_tag.inner_html = render_partial
    end

    def ruhl_swap
      current_tag.swap(call_result)
    end

    def process_results
      if call_result.is_a?(Hash)
        apply_hash(current_tag, call_result)
     else
        current_tag.inner_html = call_result.to_s
      end
    end

    def apply_hash(tag, hash)
      hash.each do |key, value|
        if key == :inner_html
          tag.inner_html = value.to_s
        else
          tag[key.to_s] = value.to_s
        end
      end
    end

    def execute_ruby(code)
      if code == '_render_'
        _render_
      else
        args = code.strip.split('|').collect{|p| p.strip}

        if block_object.respond_to?(args.first)
          block_object.send(*args)
        elsif local_object.respond_to?(args.first)
          local_object.send(*args)
        else
          scope.send(*args)
        end
      end
    rescue NoMethodError => e
      log_context(code)
      raise e
    end

    def set_scope(current_scope)
      raise Ruhl::NoScopeError unless current_scope
      @scope = current_scope 
    end

    def stop_processing?
      call_result.nil? || 
        call_result == false || 
          call_result_empty_array?
    end

    def continue_processing?
      call_result == true || call_result_populated_array?
    end

    def call_result_populated_array?
      call_result.kind_of?(Array) && !call_result.empty?

    end
    def call_result_empty_array?
      call_result.kind_of?(Array) && call_result.empty?
    end

    def log_context(code)
      Ruhl.logger.error <<CONTEXT
Context:
  tag           : #{current_tag.inspect}
  code          : #{code.inspect}
  local_object  : #{local_object.inspect}
  block_object  : #{block_object.inspect}
  scope         : #{scope.class}
CONTEXT
    end
  end # Engine
end # Ruhl
