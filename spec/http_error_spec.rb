require 'spec_helper'

require 'sidewalk/errors'

describe Sidewalk::HttpError do
  before :each do
    @error = Sidewalk::HttpError.new(:herp, :derp)
  end

  describe '#status' do
    it 'returns the status given to the constructor' do
      @error.status(nil).should == :herp
    end
  end

  describe '#description' do
    it 'returns the description given to the constructor' do
      @error.description(nil).should == :derp
    end
  end
end
