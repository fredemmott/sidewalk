require 'sidewalk/request'
require 'sidewalk/uri_mapper'

autoload :Logger, 'logger'

module Sidewalk
  class Application
    def self.local_root
      @local_root ||= File.expand_path(Dir.pwd)
    end

    def initialize urimap
      $LOAD_PATH.push Sidewalk::Application.local_root
      @mapper = Sidewalk::UriMapper.new(urimap)
    end

    def call env
      path_info = env['PATH_INFO']
      if path_info.start_with? '/'
        path_info[0,1] = ''
      end

      match = @mapper.map path_info
      if match
        controller = match.controller.new(
          Sidewalk::Request.new(env),
          ::Logger.new(env['rack.error'])
        )
        controller.response
      else
        [404, {'Content-Type' => 'text/plain'}, ['not found']]
      end
    end
  end
end
