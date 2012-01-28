require 'rack/utils'

module Sidewalk
  # A URI relative to a specified root URI.
  #
  # You probably don't want to use this directly - see {AppUri} and
  # {RelativeUri} for examples.
  module RootedUri
    # Create a new URI, relative to the specified root.
    #
    # @param [URI::Common] root is the uri that you want to use as the base
    # @param [String] path is the sub-path to add
    # @param [Hash] query is a +Hash+ of key-values to add to the query
    #   string.
    def self.new root, path, query = {}
      uri = root.dup
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
