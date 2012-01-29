module Sidewalk
  module TemplateHandlers
    class TemplateHandler
      def render controller
        raise NotImplementedError.new
      end

      protected

      def initialize path
      end
    end
  end
end
