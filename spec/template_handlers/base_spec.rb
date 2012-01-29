require 'spec_helper'

require 'sidewalk/template_handlers/base'

describe Sidewalk::TemplateHandlers::Base do
  context 'when subclassed' do
    before :all do
      @subclass = Class.new(Sidewalk::TemplateHandlers::Base)
    end

    describe '#render' do
      it 'raises a NotImplementedError if not overridden' do
        lambda{
          @subclass.new('foo').render(nil)
        }.should raise_error NotImplementedError
      end
    end
  end
end
