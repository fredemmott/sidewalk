require 'spec_helper'

require 'sidewalk/template_handlers/erb_handler'

ErbHandler = Sidewalk::TemplateHandlers::ErbHandler

views = File.expand_path('./views', File.dirname(__FILE__))

describe Sidewalk::TemplateHandlers::ErbHandler do
  it 'can render a template with simple interpolation' do
    result = ErbHandler.new(views + '/simple.erb').render(nil)
    result.should == "Hello, world.\n"
  end

  it 'can render a template with HTML escaping' do
    result = ErbHandler.new(views + '/escape.erb').render(nil)
    result.should == "foo&amp;bar\n"
  end

  it 'can render a template that uses instance variables' do
    controller = Object.new
    controller.instance_eval{ @text = 'herp' }

    handler = ErbHandler.new(views + '/instance_variable.erb')
    result = handler.render(controller)

    result.should == "herp\n"
  end
end
