require 'continuation' unless RUBY_VERSION.start_with? '1.8.'

module Sidewalk
  class Controller
    attr_reader :request, :logger

    def initialize request, logger
      @request, @logger = request, logger
    end

    def call
      catch(:sidewalk_controller_current) do
        return response
      end.call(self)
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

    def self.current
      begin
        callcc{|cc| throw(:sidewalk_controller_current, cc)}
      rescue NameError, ArgumentError
        nil
      end
    end
  end
end
