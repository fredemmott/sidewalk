module Sidewalk
  module TemplateHandlers
    # A delegate scope to run templates in.
    #
    # Used to provide templates access to the controller's instance
    # variables, and extra helper functions, without polluting the
    # controller with them. For example, {ErbHandler::Delegate} will also
    # include the standard +ERB::Util+ helper functions like +#h+ (aka
    # +#html_escape+)
    class BaseDelegate
      # A new instance of delegate.
      #
      # Copies all instance variables from controller to object.
      #
      # @param [Controller] controller
      def initialize controller
        controller.instance_variables.each do |name|
          self.instance_variable_set(
            name,
            controller.instance_variable_get(name)
          )
        end
      end

      # Render the template in the scope.
      #
      # The default implementation raises a NotImplementedError.
      #
      # @example {ErbDelegate#render}
      #   def render
      #     # @template is set by {ErbDelegate}'s constructor.
      #     @template.result binding
      #   end
      def render
        raise NotImplementedError.new
      end
    end
  end
end
