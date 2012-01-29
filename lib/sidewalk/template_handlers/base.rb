module Sidewalk
  module TemplateHandlers
    class Base
      def render controller
        raise NotImplementedError.new
      end

      def initialize path
      end
    end
  end
end
