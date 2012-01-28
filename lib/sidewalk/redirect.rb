require 'sidewalk/errors'

module Sidewalk
  # Base class for HTTP-level redirections.
  #
  # This, and its' subclasses are expected to be +raise+d.
  class Redirect < HttpError
    # Where to redirect to.
    attr_reader :url

    # Initialize a Redirect.
    #
    # You probably don't want to use this directly - use
    # {PermanentRedirect} or {SeeOtherRedirect} instead.
    #
    # @param [String, URI] url is where to redirect to
    # @param [Fixnum] status is a numeric HTTP status code
    # @param [String] description is a short description of the status
    #   code, such as 'Moved Permanently'
    def initialize url, status, description
      @url = url.to_s
      super status, description
    end
  end

  # Use if a resource has permanently moved.
  #
  # Does not change POST into GET.
  #
  # Uses a 301 Moved Permanently response.
  class PermanentRedirect < Redirect
    def initialize url
      super url, 301, 'Moved Permanently'
    end
  end

  # Use if the resource hasn't moved, but you want to redirect anyway.
  #
  # The new request will be a GET request.
  #
  # Standard usage is to redirect after a POST, to make the browser's
  # Refresh and back/forward buttons work as expected.
  #
  # Defaults to a '303 See Other', but if you need to support pre-HTTP/1.1
  # browsers, you might want to change this.
  # 
  # @example Supporting Legacy Browsers
  class SeeOtherRedirect < Redirect
    def initialize url
      super url, nil, nil
    end

    # Return an appropriate status code.
    #
    # @return +303+ for HTTP/1.1 clients
    # @return +302+ for HTTP/1.0 clients
    def status request
      if request.http_version == '1.1'
        303
      else
        302
      end
    end

    # Return an appropriate description.
    #
    # @return 'See Other' for HTTP/1.1 clients
    # @return 'Found' for HTTP/1.0 clients
    def description request
      case status(request)
      when 303
        'See Other'
      when 302
        'Found'
      end
    end
  end
end
