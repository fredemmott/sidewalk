require 'sidewalk/application'

require 'active_support/inflector'

module Sidewalk
  module ControllerMixins
    # Mixin for supporting view templates.
    #
    # This provides {#render}, which looks in views/ for a suitably named
    # file, such as +views/hello.erb' for HelloController.
    #
    # See {TemplateHandlers::Base} for a list of supported formats.
    module ViewTemplates
      # The local path where templates are stored
      #
      # This will usually be the views/ subdirectory of the application
      # root.
      def self.view_path
        @templates_path ||= File.join(
          Sidewalk::Application.local_root,
          'views'
        )
      end

      # What handler to use for a given extension.
      #
      # @example ERB
      #   erb_handler = Sidewalk::ViewTemplates.handler('erb')
      #   erb_handler.should == Sidewalk::TemplateHandlers::ErbHandler
      #
      # @param [String] a filename extension.
      # @return [Class] a {TemplateHandlers::Base} subclass.
      def self.handler type
        name = type.camelize + 'Handler'
        begin
          Sidewalk::TemplateHandlers.const_get(name)
        rescue NameError
          require ('Sidewalk::TemplateHandlers::' + name).underscore
          Sidewalk::TemplateHandlers.const_get(name)
        end
      end

      # Get a {TemplateHandlers::Base} instance for a given path.
      #
      # @return [TemplateHandlers::Base]
      def self.template path
        self.templates[path.to_s]
      end

      # A +Hash+ of all available templates.
      #
      # @return [Hash] a +path+ +=>+ {TemplateHandlers::Base} map.
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

      # Return the result of rendering a view.
      #
      # @param [nil,String] which view to render. The default is
      #   +foo_controller+ if called from +FooController+.
      # @return [String] a rendered result.
      def render view = nil
        view ||= self.class.name.sub('Controller', '').underscore
        template = Sidewalk::ControllerMixins::ViewTemplates.template(view)
        if template.nil?
          raise ScriptError.new("Unable to find a template for #{view}")
        end
        template.render(self)
      end
    end
  end
end
