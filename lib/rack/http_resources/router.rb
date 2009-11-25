module Rack::HTTPResources::Router

  def map path
    @map_point = compile path
  end

  def map_point
    map "/#{name.gsub('::', '/').downcase}" unless @map_point
    @map_point
  end

  def routes; @routes ||= {} end

  def add_route verb, path, method
    pattern, keys = compile(path)

    (routes[verb] ||= []).
      push([pattern, keys, method]).last
  end

  def compile(path)
    keys = []
    if path.respond_to? :to_str
      special_chars = %w{. + ( )}
      pattern =
        path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
          case match
          when "*"
            keys << 'splat'
            "(.*?)"
          when *special_chars
            Regexp.escape(match)
          else
            keys << $2[1..-1]
            "([^/?&#]+)"
          end
        end
      [/^#{pattern}$/, keys]
    elsif path.respond_to?(:keys) && path.respond_to?(:match)
      [path, path.keys]
    elsif path.respond_to? :match
      [path, keys]
    else
      raise TypeError, path
    end
  end

  def GET path, method
    add_route 'GET', path, method
  end

  def POST path, method
  end

  def PUT path, method
  end

  def DELETE path, method
  end

  def HEAD path, method
  end

  def route!
    if routes = routes[env[:REQUEST_METHOD]]
      path = unescape(env[:PATH_INFO])

      raise 'Opps!!' unless path =~ map_point.first
      path = "/#{$'}".squeeze '/'

      routes.each do |pattern, keys, method|
        if match = pattern.match(path)
          values = match.captures.to_a
          @request = Rack::Request.new env
          # enable nested params in Rack < 1.0; allow indifferent access
          @params =
            if Rack::Utils.respond_to?(:parse_nested_query)
              indifferent_params(@request.params)
            else
              nested_params(@request.params)
            end
          @params.merge(
            if keys.any?
              keys.zip(values).inject({}) do |hash,(k,v)|
                if k == 'splat'
                  (hash[k] ||= []) << v
                else
                  hash[k] = v
                end
                hash
              end
            elsif values.any?
                {'captures' => values}
            else
              {}
            end
          )

          send method
          break
        end
      end
    end

    raise 'missing'
  end

  # Enable string or symbol key access to the nested params hash.
  def indifferent_params(params)
    params = indifferent_hash.merge(params)
    params.each do |key, value|
      next unless value.is_a?(Hash)
      params[key] = indifferent_params(value)
    end
  end

  # Recursively replace the params hash with a nested indifferent
  # hash. Rack 1.0 has a built in implementation of this method - remove
  # this once Rack 1.0 is required.
  def nested_params(params)
    return indifferent_hash.merge(params) if !params.keys.join.include?('[')
    params.inject indifferent_hash do |res, (key,val)|
      if key.include?('[')
        head = key.split(/[\]\[]+/)
        last = head.pop
        head.inject(res){ |hash,k| hash[k] ||= indifferent_hash }[last] = val
      else
        res[key] = val
      end
      res
    end
  end

  def indifferent_hash
    Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
  end

end
