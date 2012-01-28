require 'sidewalk/controller'
require 'sidewalk/relative_uri'
require 'sidewalk/request'

module Sidewalk
  module AppUri
    def self.new path, query = {}
      context = Sidewalk::Controller.current
      unless context
        raise ScriptError.new("Only valid when called by a controller")
      end
      uri = context.request.root_uri

      Sidewalk::RelativeUri.new(uri, path, query)
    end
  end
end
