require 'sidewalk/uri_match'

require 'rack/request'
require 'uri'

module Sidewalk
  class Request
    def initialize env
      @env = env
      @rack_version = env['rack.version']

      sanity_check!
      @rack_request = Rack::Request.new(@env)

      initialize_uris
    end

    def root_uri
      @root_uri.dup
    end

    def request_uri
      @request_uri.dup
    end

    def secure?
      @secure
    end

    def get_params
      @get_params ||= @rack_request.GET
    end

    def uri_match
      @uri_match ||= @env['sidewalk.urimatch']
    end

    def post_params
      @post_params ||= @rack_request.POST
    end

    def uri_params
      uri_match.parameters
    end

    def params
      # URI parameters take precendence
      @params ||= post_params.merge(get_params.merge(uri_params))
    end

    private

    def initialize_uris
      case @env['rack.url_scheme']
      when 'http'
        @secure = false
        uri_class = URI::HTTP
      when 'https'
        @secure = true
        uri_class = URI::HTTPS
      else
        raise "Unknown URL scheme: #{@env['rack.url_scheme'].inspect}"
      end

      root = @env['SCRIPT_NAME']
      unless root.start_with? '/'
        root[0,0] = '/' # no prepend on 1.8
      end

      @root_uri = uri_class.build(
        :host => @env['SERVER_NAME'],
        :port => @env['SERVER_PORT'].to_i,
        :path => root
      ).freeze
      path_info = @env['PATH_INFO']
      if root.end_with? '/' and path_info.start_with? '/'
        path_info = path_info[1..-1]
      end
      @request_uri = @root_uri.dup
      @request_uri.path += path_info
      @request_uri.query = @env['QUERY_STRING']
      @request_uri.freeze
    end

    def sanity_check!
      # Sanity checks
      unless @rack_version
        raise ArgumentError.new "env doesn't specify a Rack version"
      end
      if @rack_version != [1, 1]
        raise "Expected Rack version [1, 1], got #{@rack_version}"
      end
    end
  end
end
