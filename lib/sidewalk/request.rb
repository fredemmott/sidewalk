require 'sidewalk/uri_match'

require 'rack/request'
require 'uri'

module Sidewalk
  # An object representing an HTTP request.
  #
  # This is meant to provide convenient, high-level functions.
  # You do have access to #{rack_environment} and #{rack_request} for
  # lower-level information, but it's best avoided.
  #
  #
  # Instances of this class are created by the {Application}.
  class Request
    # The environment array provided by Rack.
    #
    # Please don't use this directly unless you're sure you need to.
    attr_reader :rack_environment
    # An instance of +Rack::Request+.
    #
    # This is a lower-level wrapper around {#rack_environment}
    #
    # Please don't use this directly unless you're sure you need to.
    attr_reader :rack_request

    # Create a new instance from a Rack environment array
    #
    # @param [Array] env is the environment data provided by Rack.
    def initialize env
      @rack_environment = env
      @rack_version = env['rack.version']

      sanity_check!
      @rack_request = Rack::Request.new(rack_environment)

      initialize_uris
    end

    # The HTTP headers.
    #
    # This does not include Rack/CGI variables - just real HTTP headers.
    def headers
      @headers ||= rack_environment.select{|k,v| k.start_with? 'HTTP_'}
    end

    # What version of HTTP the client is using.
    #
    # @return '1.1'
    # @return '1.0'
    # @return nil
    def http_version
      @http_version ||= [
        'HTTP_VERSION',
        'SERVER_PROTOCOL',
      ].map{ |x| rack_environment[x] }.find.first.to_s.split('/').last
    end

    # The root URI of the application.
    #
    # If you're looking at this to construct an URI to another page, take a
    # look at {Sidewalk::AppUri}.
    #
    # If you want to find out where the current request was to, see {#uri}.
    #
    # @return [URI::Common]
    def root_uri
      @root_uri.dup
    end

    # The URI of the current request.
    #
    # If you're looking at this to construct a relative URI, take a look at
    # {Sidewalk::RelativeUri}.
    #
    # If you want to find out what the URI for the application is, see
    # {#root_uri}.
    #
    # @return [URI::Common]
    def uri
      @request_uri.dup
    end

    # Whether or not this request came via HTTPS.
    #
    # @return [true, false]
    def secure?
      @secure
    end

    # Parameters provided via the query string.
    #
    # Consider using {#params} instead.
    #
    # @return [Hash]
    def get_params
      @get_params ||= @rack_request.GET
    end

    # The {UriMatch} created by {UriMapper}.
    def uri_match
      @uri_match ||= rack_environment['sidewalk.urimatch']
    end

    # Paramters provided via POST.
    #
    # Consider using {#params} instead.
    #
    # @return [Hash]
    def post_params
      @post_params ||= @rack_request.POST
    end

    # Paramters provided via named captures in the URL.
    #
    # Consider using {#params} instead.
    #
    # @return [Hash]
    def uri_params
      uri_match.parameters
    end

    # Parameters provided by any means.
    #
    # Precedence:
    # * URL captures first
    # * Then query string parameters
    # * Then POST parameters
    def params
      # URI parameters take precendence
      @params ||= post_params.merge(get_params.merge(uri_params))
    end

    private

    def initialize_uris
      case rack_environment['rack.url_scheme']
      when 'http'
        @secure = false
        uri_class = URI::HTTP
      when 'https'
        @secure = true
        uri_class = URI::HTTPS
      else
        raise ArgumentError.new(
          "Unknown URL scheme: #{rack_environment['rack.url_scheme'].inspect}"
        )
      end

      root = rack_environment['SCRIPT_NAME']
      unless root.start_with? '/'
        root[0,0] = '/' # no prepend on 1.8
      end

      @root_uri = uri_class.build(
        :host => rack_environment['SERVER_NAME'],
        :port => rack_environment['SERVER_PORT'].to_i,
        :path => root
      ).freeze
      path_info = rack_environment['PATH_INFO']
      if root.end_with? '/' and path_info.start_with? '/'
        path_info = path_info[1..-1]
      end
      @request_uri = @root_uri.dup
      @request_uri.path += path_info
      @request_uri.query = rack_environment['QUERY_STRING']
      @request_uri.freeze
    end

    def sanity_check!
      # Sanity checks
      unless @rack_version
        raise ArgumentError.new(
          "env doesn't specify a Rack version"
        )
      end
      if @rack_version != [1, 1]
        raise ArgumentError.new(
          "Expected Rack version [1, 1], got #{@rack_version}"
        )
      end
    end
  end
end
