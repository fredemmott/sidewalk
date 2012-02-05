require 'sidewalk/template_handlers/base'
require 'sidewalk/template_handlers/base_delegate'

require 'rxhp'
require 'rxhp/html'

module Sidewalk
  module TemplateHandlers
    class RxhpHandler < Base
      def initialize path
        @path = path
        @template = File.read(path)
      end

      def render controller
        Delegate.new(@path, @template, controller).render
      end

      class Delegate < BaseDelegate
        include Rxhp::Html
        def initialize path, template, controller
          @path, @template, @controller = path, template, controller
          super controller
        end

        def render
          eval(@template, binding, @path).render
        end
      end
    end
  end
end
