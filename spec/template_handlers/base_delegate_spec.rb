require 'spec_helper'

require 'sidewalk/template_handlers/base_delegate'

describe Sidewalk::TemplateHandlers::BaseDelegate do
  it 'copies all instance variables from the controller class' do
    controller = Object.new
    controller.instance_eval do
      @foo = :bar
      @herp = :derp
    end

    delegate = Sidewalk::TemplateHandlers::BaseDelegate.new(controller)

    foo = delegate.instance_eval{ @foo }
    herp = delegate.instance_eval{ @herp }
    foo.should == :bar
    herp.should == :derp
  end

  describe '#render' do
    it 'raises a NotImplementedError' do
      delegate = Sidewalk::TemplateHandlers::BaseDelegate.new(nil)
      lambda{delegate.render}.should raise_error(NotImplementedError)
    end
  end
end
