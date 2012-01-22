require 'sidewalk/regexp'
require 'sidewalk/uri_match'

module Sidewalk
  class UriMapper
    attr_reader :uri_map
    def initialize uri_map = {}
      unless uri_map.is_a? Hash
        raise ArgumentError.new('URI map must be a Hash')
      end
      @uri_map = Sidewalk::UriMapper.convert_map(uri_map)
    end

    def map path
      Sidewalk::UriMapper.map(
        [], #stack
        self.uri_map,
        path
      )
    end

    # Replace string keys with Sidewalk::Regexp instances
    def self.convert_map uri_map
      out = {}
      uri_map.each do |key, value|
        # In particular, we don't want standard regexp objects -
        # those don't support named captures on 1.8
        unless key.is_a? String
          raise ArgumentError.new('URI map keys must be strings')
        end

        unless key.include? '^'
          key = '^' + key
        end

        key = Sidewalk::Regexp.new(key)
        if value.is_a? Hash
          out[key] = convert_map(value)
        else
          out[key] = value
        end
      end
      out
    end

    def self.map stack, uri_map, path
      uri_map.each do |re, next_map|
        match = re.match(path)
        next unless match

        stack.push re.source[1..-1] # get rid of the '^' added

        case next_map
        when Hash
          return map(stack, next_map, match.post_match)
        else
          params = {}
          match.names.each do |name|
            value = match[name]
            params[name.to_sym] = value if value
          end

          return UriMatch.new(
            stack,
            params,
            next_map
          )
        end
      end
      nil
    end
  end
end
