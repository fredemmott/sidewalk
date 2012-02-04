require 'sidewalk/template_handlers/base'
require 'sidewalk/template_handlers/base_delegate'

require 'haml'

module Sidewalk
  module TemplateHandlers
    class HamlHandler < Base
      def initialize path
        super path
        @engine = Haml::Engine.new(File.read(path))
      end

      def render controller
        @engine.render(BaseDelegate.new(controller))
      end
    end
  end
end
