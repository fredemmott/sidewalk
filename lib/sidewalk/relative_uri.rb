require 'sidewalk/controller'
require 'sidewalk/rooted_uri'
require 'sidewalk/request'

module Sidewalk
  # URI relative to the current request.
  #
  # For example, if your app lives at 'http://www.example.com/foo',
  # the current request is to '/foo/bar', +RelativeUri.new('/baz').to_s+
  # will return 'http://www.example.com/foo/bar/baz', whereas {AppUri}
  # would give you 'http://www.example.com/foo/baz'.
  #
  # Existing query data is discarded.
  #
  # Not a real class as the +URI+ hierarchy doesn't lend itself to
  # subclassing.
  module RelativeUri
    # Create a URI relative to the current request.
    #
    # If this is called, it _must_ have {Controller#call} in the call stack
    # so that {Controller#current} works - otherwise it does not have
    # enough information to construct the URI.
    #
    # Query string data is discarded.
    #
    # @param [String] path is the path relative to the current request.
    # @param [Hash] query is a +Hash+ of key-value query data.
    def self.new path, query = {}
      context = Sidewalk::Controller.current
      unless context
        raise ScriptError.new("Only valid when called by a controller")
      end
      uri = context.request.uri

      Sidewalk::RootedUri.new(uri, path, query)
    end
  end
end
