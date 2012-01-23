require 'sidewalk/template_handlers/template_handler'

require 'erb'

module Sidewalk
  module TemplateHandlers
    class ErbHandler < TemplateHandler
      def initialize path
        super path
        @template = ERB::new(File.read(path))
      end

      def render binding
        @template.result(binding)
      end
    end
  end
end
