module Sidewalk
  # Base class for HTTP errors.
  #
  # This is +raise+d by controllers.
  class HttpError < ::RuntimeError
    # Initialize an Error exception.
    #
    # If the parameters are +nil+, you will need to override {#status} and
    # {#description} for this class to work as expected.
    #
    # @param [Fixnum,nil] status is the numeric status code
    # @param [String,nil] description is a short description like 'Not
    #   Found'
    def initialize status, description
      @status, @description = status, description
    end

    # The status code to return in response to the request.
    #
    # It takes a request to allow different responses to be given to,
    # for example, HTTP/1.0 clients vs HTTP/1.1 clients.
    #
    # @param [Request] request is an object representing the current HTTP
    #   request
    # @return [Fixnum] a numeric HTTP status code.
    def status request
      @status
    end

    # The description to return in response to the request.
    #
    # It takes a request to allow different responses to be given to,
    # for example, HTTP/1.0 clients vs HTTP/1.1 clients.
    #
    # @param [Request] request is an object representing the current HTTP
    #   request
    # @return [String] a text description of the code, like 'Not Found'
    def description request
      @description
    end
  end

  # Request that the client provide authentication headers.
  #
  # This is a 401 response
  class NotAuthorizedError < HttpError
    def initialize
      super 401, 'Not Authorized'
    end
  end

  # Forbid the client from accessing a resource.
  #
  # Providing authentication headers will not help.
  #
  # This is a 403 response.
  class ForbiddenError < HttpError
    def initialize
      super 403, 'Forbidden'
    end
  end

  # Tells the client that the resource they requested does not exist.
  #
  # This is a 404 response.
  class NotFoundError < HttpError
    def initialize
      super 404, 'Not Found'
    end
  end
end
