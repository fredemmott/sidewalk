require 'sidewalk/application'

require 'active_support/inflector'

module Sidewalk
  module ControllerMixins
    module ViewTemplates
      def self.view_path
        @templates_path ||= File.join(
          Sidewalk::Application.local_root,
          'views'
        )
      end

      def self.handler type
        name = type.camelize + 'Handler'
        begin
          Sidewalk::TemplateHandlers.const_get(name)
        rescue NameError
          require ('Sidewalk::TemplateHandlers::' + name).underscore
          Sidewalk::TemplateHandlers.const_get(name)
        end
      end

      def self.template path
        self.templates[path.to_s]
      end

      def self.templates
        return @templates if @templates

        @templates = {}
        Dir.glob(
          self.view_path + '/**/*'
        ).each do |path| # eg '/path/views/foo/bar.erb'

          # eg '.erb'
          ext = File.extname(path)
          # eg 'erb'
          type = ext[1..-1]
          handler = self.handler(type)

          # eg 'foo/bar.erb'
          relative = path.sub(self.view_path + '/', '')
          # convert to 'foo/bar'
          parts = relative.split('/')
          parts[-1] = File.basename(path, ext)
          key = parts.join('/')

          @templates[key] = handler.new(path)
        end
        @templates
      end

      def render view = nil
        view ||= self.class.name.sub('Controller', '').underscore
        template = Sidewalk::ControllerMixins::ViewTemplates.template(view)
        template.render(binding)
      end
    end
  end
end
