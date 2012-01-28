require 'sidewalk/controller'
require 'sidewalk/rooted_uri'
require 'sidewalk/request'

module Sidewalk
  # URI relative to the root of the application.
  #
  # For example, if your app lives at 'http://www.example.com/foo',
  # +AppUri.new('/bar').to_s+ will reutrn 'http://www.example.com/foo/bar'.
  #
  # Not a real +URI+ subclass, as URI subclasses by protocol, and this
  # might return a +URI::HTTP+ or +URI::HTTPS+ subclass.
  module AppUri
    # Create a URI relative to the application.
    #
    # If this is called, it _must_ have {Controller#call} in the call stack
    # so that {Controller#current} works - otherwise it does not have
    # enough information to construct the URI.
    #
    # @param [String] path is the path relative to the root of the
    #   application.
    # @param [Hash] query is a +Hash+ of key-value query data.
    def self.new path, query = {}
      context = Sidewalk::Controller.current
      unless context
        raise ScriptError.new("Only valid when called by a controller")
      end
      uri = context.request.root_uri

      Sidewalk::RootedUri.new(uri, path, query)
    end
  end
end
