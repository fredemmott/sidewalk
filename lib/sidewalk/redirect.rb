require 'sidewalk/errors'

module Sidewalk
  class Redirect < HttpError
    attr_reader :url

    protected

    def initialize url, status, description
      @url = url
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

    def status request
      if request.http_version == '1.1'
        303
      else
        302
      end
    end

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
