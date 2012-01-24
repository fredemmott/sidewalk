require 'sidewalk/request'
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
      path_info = env['PATH_INFO']
      if path_info.start_with? '/'
        path_info[0,1] = ''
      end

      match = @mapper.map path_info
      if match
        env['sidewalk.urimatch'] = match

        if match.controller.is_a? Class
          responder = lambda do |request, logger|
            match.controller.new(request, logger).response
          end
        else
          responder = match.controller
        end

        responder.call(
          Sidewalk::Request.new(env),
          ::Logger.new(env['rack.error'])
        )
      else
        [404, {'Content-Type' => 'text/plain'}, ['not found']]
      end
    end
  end
end
