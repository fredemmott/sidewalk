require 'spec_helper'

require 'sidewalk/template_handlers/haml_handler'

HamlHandler = Sidewalk::TemplateHandlers::HamlHandler

views = File.expand_path('./views', File.dirname(__FILE__))

describe Sidewalk::TemplateHandlers::HamlHandler do
  it 'can render a template with simple interpolation' do
    result = HamlHandler.new(views + '/simple.haml').render(nil)
    result.should == "<div id='root'>Hello, world.</div>\n"
  end

  it 'can render a template with HTML escaping' do
    result = HamlHandler.new(views + '/escape.haml').render(nil)
    result.should include "foo&amp;bar"
  end

  it 'can render a template that uses instance variables' do
    controller = Object.new
    controller.instance_eval{ @text = 'herp' }

    handler = HamlHandler.new(views + '/instance_variable.haml')
    result = handler.render(controller)

    result.should include 'herp'
  end
end
