require 'sidewalk/app_uri'

require 'rack/utils'

require 'continuation' unless RUBY_VERSION.start_with? '1.8.'
require 'time' # Rack::Utils.set_cookie_header! on Ruby 1.8

module Sidewalk
  # Base class for page controllers.
  #
  # {UriMapper} maps URIs to classes or Procs. If it maps to a class, that
  # class needs to implement {#initialize} and {#call} in the same way as
  # this class. This class provides some added convenience.
  #
  # You might want to look at {ControllerMixins} for some additional
  # optional features.
  #
  # To handle an URL, you will usually want to:
  # * subclass this
  # * implement {#response}
  # * add your class to your application URI map.
  class Controller
    # Initialize a new controller instance.
    #
    # @param [Request] request has information on the HTTP request.
    # @param [Logger] logger is something implement the same interface as
    #   Ruby's +Logger+ class.
    def initialize request, logger
      @request, @logger = request, logger
      @status = 200
      @headers = {
        'Content-Type' => 'text/html'
      }
    end

    # The response headers.
    #
    # For request headers, see {#request} and {Request#headers}.
    attr_reader :headers

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

    # Set a cookie :)
    #
    # Valid options are:
    # +:expires+:: accepts a +Time+. Default is a session cookie.
    # +:secure+:: if +true+, only send the cookie via https
    # +:httponly+:: do not allow Flash, JavaScript etc to access the cookie
    # +:domain+:: restrict the cookie to only be available on a given
    #             domain, and subdomains. Default is the request domain.
    # +:path+:: make the cookie accessible to other paths - default is the
    #           request path.
    #
    # @param key [String] is the name of the cookie to set
    # @param value [Object] is the value to set - as long as it responds to
    #   +#to_s+, it's fine.
    def set_cookie key, value, options = {}
      rack_value = options.dup
      rack_value[:value] = value.to_s
      Rack::Utils.set_cookie_header! self.headers, key.to_s, rack_value
    end

    # What mime-type to return to the user agent.
    #
    # "text/html" is the default.
    def content_type
      headers['Content-Type']
    end

    def content_type= value
      headers['Content-Type'] = value
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

  # Optional extension features to the Controller class.
  #
  # @example Adding +#render+ and supporting +views/+
  #   class MyController < Sidewalk::Controller
  #     include Sidewalk::ControllerMixins::ViewTemplates
  #     def response
  #       # Look for 'views/my_controller.*' - for example,
  #       # 'views/my_controller.erb' would be rendered with ERB if
  #       # present.
  #       render
  #     end
  #   end
  module ControllerMixins
    # see controller_mixins/
  end
end
