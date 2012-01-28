require 'continuation' unless RUBY_VERSION.start_with? '1.8.'

module Sidewalk
  # Base class for page controllers.
  #
  # {UriMapper} maps URIs to classes or Procs. If it maps to a class, that
  # class needs to implement {#initialize} and {#call} in the same way as
  # this class. This class provides some added convenience.
  #
  # To handle an URL, you will usually want to:
  # * subclass this
  # * implement {#payload}
  # * add your class to your application URI map.
  class Controller
    # The instance of {Request} corresponding to the current HTTP request.
    attr_reader :request
    # An object implementing an interface that is compatible with +Logger+
    attr_reader :logger
    # The numeric HTTP status to return.
    #
    # In most cases, you won't actually want to change this - you might
    # want to +raise+ an instance of a subclass of {HttpError} or
    # {Redirect} instead.
    attr_accessor :status
    # What mime-type to return to the user agent.
    #
    # "text/html" is the default.
    attr_accessor :content_type

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
