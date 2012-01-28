module Sidewalk
  # Base class for HTTP errors.
  class HttpError < ::RuntimeError
    def initialize status, description
      @status, @description = status, description
    end

    def status request
      @status
    end

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
  class ForbiddenError < HttpError
    def initalize
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
