module Sidewalk
  module TemplateHandlers
    class TemplateHandler

      def initialize path
      end

      # Re
      #
      # It should return a Proc that:
      # - takes a binding as a parameter
      # - returns a string
      #
      # This method is called with a full path to a template file.
      def render binding
        raise NotImplementedError.new
      end
    end
  end
end
