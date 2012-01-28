require 'rack/utils'

module Sidewalk
  module RootedUri
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
