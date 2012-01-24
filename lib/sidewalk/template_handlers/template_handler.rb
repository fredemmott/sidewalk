module Sidewalk
  module TemplateHandlers
    class TemplateHandler

      def initialize path
      end

      # Re
      #
      # It should return a Proc that:
      # - takes a controller instance as a parameter
      # - returns a string
      #
      # This method is called with a full path to a template file.
      def render controller
        raise NotImplementedError.new
      end
    end
  end
end
