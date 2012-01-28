require 'sidewalk/request'
require 'sidewalk/errors'
require 'sidewalk/redirect'
require 'sidewalk/uri_mapper'

autoload :Logger, 'logger'

module Sidewalk
  # The main Rack Application.
  #
  # This class is responsible for dispatch requests (based on a
  # {Sidewalk::UriMapper}), and handling some exceptions, such as
  # {NotFoundError}, {ForbiddenError}, or {SeeOtherRedirect}.
  #
  # If you want special error handling, subclass this, and reimplement
  # {#respond_to_error}.
  class Application
    # The {UriMapper} class this application is using.
    #
    # This is constructed from the uri_map Hash argument to {#initialize}.
    attr_reader :mapper

    # The path on the server where the application code is.
    #
    # This should be the path containing config.ru. This will be something
    # like +/var/www+, or +/home/fred/public_html+.
    def self.local_root
      @local_root ||= Dir.pwd
    end

    # Construct an instance, based on a URI-mapping Hash.
    #
    # @param [Hash] uri_map is a +String+ => +Class+, +Symbol+, +String+,
    #   or +Proc+ map. See {UriMapper#initialize} for details of acceptable
    #   keys; the short version is that they are +String+s that contain
    #   regular expression patterns. They are not +Regexp+s.
    def initialize uri_map
      @mapper = Sidewalk::UriMapper.new(uri_map)
    end

    # Per-request Rack entry point.
    #
    # This is called for every request. It's responsible for:
    # * Normalizing the environment parameter
    # * Finding what should respond to the request (via {UriMapper})
    # * Actually responding
    # * Error handling - see {#handle_error}
    #
    # @param [Hash] env is an environment +Hash+, defined in the Rack
    #   specification.
    def call env
      logger = ::Logger.new(env['rack.error'])

      path_info = env['PATH_INFO']
      if path_info.start_with? '/'
        path_info[0,1] = ''
      end

      match = @mapper.map path_info
      if match
        env['sidewalk.urimatch'] = match
        # Normalize reponders to Procs
        if match.controller.is_a? Class
          responder = lambda do |request, logger|
            match.controller.new(request, logger).response
          end
        else
          responder = match.controller
        end
      else
        responder = lambda { |*args| raise NotFoundError.new }
      end

      request = Sidewalk::Request.new(env)

      # Try and call - but it can throw special exceptions that we
      # want to map into HTTP status codes - for example, NotFoundError
      # is a 404
      begin
        responder.call(
          request,
          logger
        )
      rescue Exception => e
        response = respond_to_error(e, request, logger)
        raise if response.nil? || response.empty?
        response
      end
    end

    # Give a response for a given error.
    #
    # If you want custom error pages, you will want to subclass
    # {Application}, reimplementing this method. At a minimum, you will
    # probably want to include support for:
    # * {HttpError}
    # * {Redirect}
    #
    # This implementation has hard-coded responses in the format defined in
    # the Rack specification.
    #
    # @example An implementation that uses {Controller} subclasses:
    #   def respond_to_error(error, request, logger)
    #     case error
    #     when Redirect
    #       MyRedirectController.new(error, request, logger).call
    #     when HttpError
    #       # ...
    #     else
    #       super(error, request, logger)
    #     end
    #   end
    #
    # @param [Exception] error is the error that was +raise+d
    # @param [Request] request gives information on the request that
    #   led to the error.
    # @param [Logger] logger is something implementing a similiar API
    #   to Ruby's standard +Logger+ class.
    #
    # @return A Rack response +Array+ - i.e.:
    #         +[status, headers, body_parts]+ - see the specification for
    #         details.
    # @return +nil+ to indicate the error isn't handled - it will get
    #         escalated to Rack and probably lead to a 500.
    def respond_to_error(error, request, logger)
      case error
      when Redirect
        [
          error.status(request),
          {
            'Content-Type' => 'text/plain',
            'Location' => error.url,
          },
          "#{error.status(request)} #{error.description(request)}"
        ]
      when HttpError
        [
          error.status(request),
          {
            'Content-Type' => 'text/plain',
          },
          "#{error.status(request)} #{error.description(request)}"
        ]
      else
        nil
      end
    end
  end
end
