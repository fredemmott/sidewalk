module Sidewalk
  module TemplateHandlers
    class BaseDelegate
      def initialize controller
        controller.instance_variables.each do |name|
          self.instance_variable_set(
            name,
            controller.instance_variable_get(name)
          )
        end
      end

      def render
        raise NotImplementedError.new
      end
    end
  end
end
