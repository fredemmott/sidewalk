module Sidewalk
  class Controller
    attr_reader :request, :logger

    def initialize request, logger
      @request, @logger = request, logger
    end

    def response
      [200, {'Content-Type' => 'text/html'}, [payload]]
    end

    def relative_uri path
      uri = request.uri
      uri.path += path
      uri
    end

    def payload
      raise NotImplementedError.new
    end
  end
end
