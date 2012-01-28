require 'sidewalk/request'
require 'sidewalk/errors'
require 'sidewalk/redirect'
require 'sidewalk/uri_mapper'

autoload :Logger, 'logger'

module Sidewalk
  class Application
    attr_reader :mapper
    def self.local_root
      @local_root ||= Dir.pwd
    end

    def initialize urimap
      @mapper = Sidewalk::UriMapper.new(urimap)
    end

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
