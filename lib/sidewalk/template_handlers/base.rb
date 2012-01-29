module Sidewalk
  module TemplateHandlers
    # Base class for TemplateHandlers.
    #
    # This currently just defines an interface - see {ErbHandler} for an
    # example.
    #
    # Instances of this class may be re-used between requests. Anything
    # request-specific needs to go in the {#render} method.
    class Base
      # Actually render a template.
      #
      # @param {Controller} controller is the controller that wants the
      #   template. Instance variables should be available to the template,
      #   and the handler should not change the scope. See {BaseDelegate}
      #   and {ErbHandler::Delegate} for an approach to this.
      #
      # @return [String]
      def render controller
        raise NotImplementedError.new
      end

      # A new instance of the controller.
      #
      # @param [String] path a full path to a template source file.
      def initialize path
      end
    end
  end
end
