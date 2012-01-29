require 'spec_helper'

require 'sidewalk/controller_mixins/view_templates'

ViewTemplates = Sidewalk::ControllerMixins::ViewTemplates

describe Sidewalk::ControllerMixins::ViewTemplates do
  describe '.view_path' do
    it 'returns view/ relative to the root' do
      ViewTemplates.view_path.should == File.expand_path('./views')
    end
  end

  describe '#handler' do
    it 'should find ErbHandler for "erb"' do
      ViewTemplates.handler('erb').name.should == 'Sidewalk::TemplateHandlers::ErbHandler'
    end

    it 'should raise a LoadError for an invalid template type' do
      lambda{ViewTemplates.handler('_________')}.should raise_error
    end

    it 'should auto-require a handler if possible' do
      lambda{ViewTemplates.handler('foo')}.should raise_error
      begin
        $LOAD_PATH.push File.expand_path('./lib', File.dirname(__FILE__))
        handler = ViewTemplates.handler('foo')
        handler.name.should == 'Sidewalk::TemplateHandlers::FooHandler'
      ensure
        $LOAD_PATH.pop
      end
    end
  end

  describe '#template' do
    before :each do
      ViewTemplates.should_receive(
        :templates
      ).and_return({'foo' => :fake_template})
    end

    it 'should fetch a template handler by string' do
      ViewTemplates.template('foo').should == :fake_template
    end

    it 'should fetch a template handler by symbol' do
      ViewTemplates.template(:foo).should == :fake_template
    end

    it 'should not return a template when there is no match' do
      ViewTemplates.template(:bar).should be_nil
    end
  end

  describe '#templates' do
    before :each do
      ViewTemplates.should_receive(
        :view_path
      ).any_number_of_times.and_return(
        File.expand_path('./views', File.dirname(__FILE__))
      )
    end

    it 'should return a Hash' do
      ViewTemplates.templates.should be_a Hash
    end

    it 'should return a non-empty Hash' do
      ViewTemplates.templates.should_not be_empty
    end

    it 'should return an ErbHandler for hello' do
      handler = ViewTemplates.templates['hello']
      handler.class.name.should == 'Sidewalk::TemplateHandlers::ErbHandler'
    end
  end

  describe '#render' do
    before :all do
      HelloController.send(:include, ViewTemplates)
    end

    it 'should default to using the underscored controller name' do
      HelloController.new(nil,nil).render.should == "Hello, world.\n"
    end

    it 'should allow an overriden template name' do
      HelloController.new(nil,nil).render(:goodbye).should == "Goodbye.\n"
    end

    it 'should raise an error if given an invalid template name' do
      lambda {
        HelloController.new(nil, nil).render(:does_not_exist)
      }.should raise_error(ScriptError)
    end
  end
end
