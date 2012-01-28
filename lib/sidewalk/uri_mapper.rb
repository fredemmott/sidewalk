require 'sidewalk/regexp'
require 'sidewalk/uri_match'

require 'active_support/inflector'

module Sidewalk
  autoload :Application, 'sidewalk/application'

  # Maps URIs to Controllers.
  #
  # Used to decide how to respond to a given HTTP request.
  class UriMapper
    # Initialize a UriMapper.
    #
    # This converts a convenient-to-write map into a fast-to-lookup map.
    #
    # The input hash takes +String+ regular expression patterns as keys,
    # and values can either be another map, a {Controller} class (not an
    # instance), a +Symbol+ or +String+ that is the name of a {Controller}
    # class, or a +Proc+.
    #
    # If the value is a +String+, it will:
    # * see if a +Class+ with the same name exists; if so, use that.
    # * try to +require+ +foo_bar_controller.rb+ for 'FooBarController'
    # * see if a +Class+ now exists with the same name
    # * if so, done; if not, bail out.
    #
    # It looks for controller files in
    # {Application#local_root}+/controllers+
    #
    # You usually won't interact with this class directly - instead you'll
    # usually pass the input hash to {Sidewalk::Application}.
    #
    # Keys are required to be +String+s instead of +Regexp+s because they
    # are converted to a +Sidewalk::+{Regexp} behind the scenes; this is
    # is the same thing as a +::Regexp+ on Ruby 1.9, but on Ruby 1.8 it
    # adds several additional features such as named captures.
    #
    # @example A Simple Map
    #   urimap = {
    #     '$' => :IndexController,
    #     'hello$' => :HelloController,
    #   }
    #   run Sidewalk::Application.new(urimap)
    #
    # @example A Nested Map
    #   urimap = {
    #     '$' => :IndexController,
    #     'foo/' => {
    #       '$' => :FooController,
    #       'bar$' => :FooBarController,
    #     },
    #   }
    #   run Sidewalk::Application.new(urimap)
    #
    # @example A Map With Named Captures
    #   urimap = {
    #     '$' => :IndexController,
    #     'foo/$' => :FooController,
    #     '~(?<username>[^/]+)/$' => :UserController
    #   }
    #   run Sidewalk::Application.new(urimap)
    #
    # @param [Hash] uri_map
    def initialize uri_map = {}
      unless uri_map.is_a? Hash
        raise ArgumentError.new('URI map must be a Hash')
      end
      $LOAD_PATH.push File.join(
        Sidewalk::Application.local_root,
        'controllers'
      )
      @uri_map = Sidewalk::UriMapper.convert_map(uri_map)
      $LOAD_PATH.pop
    end

    # Given a path, find what should respond to it.
    #
    # @return [UriMatch] if something was found.
    # @return [nil] if there is no match.
    def map path
      Sidewalk::UriMapper.map(
        [], #stack
        self.uri_map,
        path
      )
    end

    # The normalized URI map.
    #
    # @return [Hash<Regexp,(Controller|Proc)>]
    attr_reader :uri_map

    private

    # Convert uri_map from easy-to-write to fast-to-use.
    #
    # - Replace string keys with Sidewalk::Regexp instances
    # - Attempt to load classes for symbols
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
        elsif value.is_a? Class
          out[key] = value
        elsif value.to_s.end_with? 'Controller'
          # Attempt to load the class
          begin
            out[key] = value.to_s.constantize
          rescue NameError
            require value.to_s.underscore
            retry
          end
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
          match.names.map.each do |name|
            # the symbol vs string stuff is because of differences between
            # Regexp on Ruby 1.9 and Oniguruma::ORegexp on Ruby 1.8
            symbol = name.to_sym
            string = name.to_s

            value = match[symbol]
            if value
              params[string] = value
              params[symbol] = value
            end
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
