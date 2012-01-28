require 'continuation' unless RUBY_VERSION.start_with? '1.8.'
require 'sidewalk/app_uri'

module Sidewalk
  # Base class for page controllers.
  #
  # {UriMapper} maps URIs to classes or Procs. If it maps to a class, that
  # class needs to implement {#initialize} and {#call} in the same way as
  # this class. This class provides some added convenience.
  #
  # To handle an URL, you will usually want to:
  # * subclass this
  # * implement {#response}
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

    # Initialize a new controller instance.
    #
    # @param [Request] request has information on the HTTP request.
    # @param [Logger] logger is something implement the same interface as
    #   Ruby's +Logger+ class.
    def initialize request, logger
      @request, @logger = request, logger
      @status = 200
      @content_type = 'text/html'
    end

    # Actually respond to the request.
    #
    # This calls {#response}, then ties it together with {#status}
    # and {#content_type}.
    #
    # @return a response in Rack's +Array+ format.
    def call
      cc = catch(:sidewalk_controller_current) do
        body = self.response
        return [status, {'Content-Type' => content_type}, [body]]
      end
      cc.call(self) if cc
    end

    # The body of the HTTP response to set.
    #
    # In most cases, this is what you'll want to implement in a subclass.
    # You can call {#status=}, but you probably don't want to - just raise
    # an appropriate {HttpError} subclass instead.
    #
    # You might be interested in {ControllerMixins::ViewTemplates}.
    #
    # @return [String] the body of the HTTP response
    def response
      raise NotImplementedError.new
    end

    # The current Controller.
    #
    # @return [Controller] the current Controller if {#call} is in the
    #   stack.
    # @return +nil+ otherwise.
    def self.current
      begin
        callcc{|cc| throw(:sidewalk_controller_current, cc)}
      rescue NameError, ArgumentError # 1.8 and 1.9 are different
        nil
      end
    end
  end
end
