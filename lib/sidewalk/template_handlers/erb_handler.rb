require 'sidewalk/template_handlers/base'
require 'sidewalk/template_handlers/base_delegate'

require 'erb'

module Sidewalk
  module TemplateHandlers
    class ErbHandler < Base
      def initialize path
        super path
        @template = ERB::new(File.read(path))
        @template.filename = path
      end

      def render controller
        Delegate.new(@template, controller).render
      end

      # Class representing the controller to ERB.
      #
      # Using a delegate so we can add extra methods to the binding
      # without polluting the class - for example, most people expect an
      # ERB template to have access to ERB::Util#h
      class Delegate < BaseDelegate
        # Pull in '#html_escape' aka '#h
        include ERB::Util

        def initialize template, controller
          p [__FILE__, __LINE__]
          @template = template
          super controller
        end

        def render
          @template.result binding
        end
      end
    end
  end
end
