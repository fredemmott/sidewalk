require 'spec_helper'
require 'sidewalk/errors'

describe Sidewalk::NotFoundError do
  describe '#status' do
    it 'should be 404' do
      Sidewalk::NotFoundError.new.status(nil).should == 404
    end
  end

  describe '#description' do
    it 'should be "Not Found"' do
      Sidewalk::NotFoundError.new.description(nil).should == 'Not Found'
    end
  end
end
