require 'spec_helper'

require 'sidewalk/config'

describe Sidewalk::Config do
  it 'raises an error if no environment is set.' do
    lambda{Sidewalk::Config.new('.')}.should raise_error
  end

  context 'with environment set to "production"' do
    before :all do
      Sidewalk::Config.environment = 'production'
    end

    it 'doesnt error if no config files are present' do
      lambda{Sidewalk::Config.new('.')}.should_not raise_error
    end

    describe '#production?' do
      it 'returns true' do
        Sidewalk::Config.production?.should be_true
      end
    end

    describe '#testing?' do
      it 'returns false' do
        Sidewalk::Config.testing?.should be_false
      end
    end

    describe '#development?' do
      it 'returns false' do
        Sidewalk::Config.development?.should be_false
      end
    end

    describe '#load_ruby!' do
      it 'raises an error if given an invalid path' do
        lambda{
          Sidewalk::Config.load_ruby! 'does_not_exit'
        }.should raise_error
      end
    end

    describe '#load_yaml!' do
      it 'raises an error if given an invalid path' do
        lambda{
          Sidewalk::Config.load_yaml! 'does_not_exit'
        }.should raise_error
      end
    end

    describe '#[]=' do
      it 'sets a value that can be retrieved by #[]' do
        Sidewalk::Config[:herp] = :derp
        Sidewalk::Config[:herp].should == :derp
      end
    end


    describe '#instance' do
      it 'returns an instance of Config' do
        Sidewalk::Config.instance.should be_a Sidewalk::Config
      end

      it 'it doesnt generate a new Config each time' do
        first = Sidewalk::Config.instance
        second = Sidewalk::Config.instance
        first.should be second
      end
    end

    context 'with a valid path set' do
      before :each do
        @config = Sidewalk::Config.new(
          File.expand_path('./config', File.dirname(__FILE__))
        )
      end

      it 'loads environment.rb' do
        $LOADED_ENVIRONMENT_RB.should be_true
      end

      it 'loads production.rb' do
        $LOADED_PRODUCTION_RB.should be_true
      end

      it 'loads environment.yaml' do
        @config['loaded_environment'].should be_true
      end

      it 'loads production.yaml' do
        @config['loaded_production'].should be_true
      end
    end
  end
end
