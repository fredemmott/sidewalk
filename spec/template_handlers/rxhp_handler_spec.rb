require 'spec_helper'

require 'sidewalk/template_handlers/rxhp_handler'

RxhpHandler = Sidewalk::TemplateHandlers::RxhpHandler

views = File.expand_path('./views', File.dirname(__FILE__))

describe Sidewalk::TemplateHandlers::RxhpHandler do
  it 'can render a template with simple interpolation' do
    result = RxhpHandler.new(views + '/simple.rxhp').render(nil)
    result.should == "Hello, world."
  end

  it 'can render a template with HTML escaping' do
    result = RxhpHandler.new(views + '/escape.rxhp').render(nil)
    result.should == "foo&amp;bar"
  end

  it 'can render a template that uses instance variables' do
    controller = Object.new
    controller.instance_eval{ @text = 'herp' }

    handler = RxhpHandler.new(views + '/instance_variable.rxhp')
    result = handler.render(controller)

    result.should == "herp"
  end

  it 'correctly renders html' do
    handler = RxhpHandler.new(views + '/html.rxhp')
    result = handler.render(nil)
    result.gsub! />[ \n]+/, '>'
    result.gsub! /[ \n]+</, '<'
    result.should == '<!DOCTYPE html><html><body>herp</body></html>'
  end
end
