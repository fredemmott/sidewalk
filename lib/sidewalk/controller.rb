module Sidewalk
  class Controller
    attr_reader :request, :logger

    def initialize request, logger
      @request, @logger = request, logger
    end

    def response
      [200, {'Content-Type' => 'text/html'}, [content]]
    end

    def content
      raise NotImplementedError.new
    end
  end
end
