require 'sidewalk/template_handlers/template_handler'

require 'erb'

module Sidewalk
  module TemplateHandlers
    class ErbHandler < TemplateHandler
      def initialize path
        super path
        @template = ERB::new(File.read(path))
      end

      def render controller
        Delegate.new(@template, controller).render
      end

      # Class representing the controller to ERB.
      #
      # Using a delegate so we can add extra methods to the binding
      # without polluting the class - for example, most people expect an
      # ERB template to have access to ERB::Util#h
      class Delegate
        # Pull in '#html_escape' aka '#h
        include ERB::Util

        def initialize template, controller
          controller.instance_variables.each do |name|
            self.instance_variable_set(
              name,
              controller.instance_variable_get(name)
            )
          end
          @template = template
          @controller = controller
        end

        def method_missing *args
          @controller.send *args
        end

        def render
          @template.result binding
        end
      end
    end
  end
end
