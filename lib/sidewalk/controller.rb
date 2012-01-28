require 'continuation' unless RUBY_VERSION.start_with? '1.8.'

module Sidewalk
  class Controller
    attr_reader :request, :logger
    attr_accessor :status, :content_type

    def initialize request, logger
      @request, @logger = request, logger
      @status = 200
      @content_type = 'text/html'
    end

    def call
      catch(:sidewalk_controller_current) do
        return response
      end.call(self)
    end

    def response
      [status, {'Content-Type' => content_type}, [payload]]
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