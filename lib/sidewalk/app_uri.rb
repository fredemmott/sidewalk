require 'sidewalk/controller'
require 'sidewalk/request'

require 'rack/utils'

module Sidewalk
  module AppUri
    def self.new path, query = {}
      context = Sidewalk::Controller.current
      unless context
        raise ScriptError.new("Only valid when called by a controller")
      end
      uri = context.request.root_uri

      root_path = uri.path
      root_path = root_path[0..-2] if root_path.end_with? '/'
      uri.path = root_path + path

      query_string = query.map do |k,v|
        '%s=%s' % [
          Rack::Utils.escape(k.to_s),
          Rack::Utils.escape(v.to_s),
        ]
      end.join('&')
      uri.query = query_string unless query.empty?

      uri
    end
  end
end
