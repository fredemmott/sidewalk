require 'spec_helper'
require 'sidewalk/uri_match'

describe Sidewalk::UriMatch do
  describe '#initialize' do
    it 'does not require any arguments' do
      lambda{ Sidewalk::UriMatch.new }.should_not raise_error
    end

    it 'accepts an Array as the first argument' do
      lambda{ Sidewalk::UriMatch.new([]) }.should_not raise_error
    end

    it 'does not accept something arbitrary as the first argument' do
      lambda do
        Sidewalk::UriMatch.new(123)
      end.should raise_error ArgumentError
    end

    it 'accepts a Hash as the second argument' do
      lambda{ Sidewalk::UriMatch.new([], {}) }.should_not raise_error
    end

    it 'does not accept something arbitrary as the second argument' do
      lambda do
        Sidewalk::UriMatch.new([], 123)
      end.should raise_error ArgumentError
    end

    it 'accepts any object as the third object' do
      lambda do
        Sidewalk::UriMatch.new([], {}, Object.new)
      end.should_not raise_error
    end
  end

  context 'when default-constructed' do
    before :each do
      @match = Sidewalk::UriMatch.new
    end

    describe '#controller' do
      it 'should be nil' do
        @match.controller.should be_nil
      end
    end

    describe '#parts' do
      it 'should be an empty Array' do
        @match.parts.should == []
      end
    end

    describe '#parameters' do
      it 'should be an empty Hash' do
        @match.parameters.should == {}
      end
    end
  end

  context 'when fully-constructed' do
    it 'should return the correct data' do
      parts = [1, 2, 3]
      params = { :foo => :bar }
      controller = Object.new
      match = Sidewalk::UriMatch.new(parts, params, controller)
      match.parts.should == parts
      match.parameters.should == params
      match.controller.should == controller
    end
  end
end
