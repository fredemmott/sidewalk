require 'spec_helper'
require 'sidewalk/errors'

describe Sidewalk::NotAuthorizedError do
  describe '#status' do
    it 'should be 401' do
      Sidewalk::NotAuthorizedError.new.status(nil).should == 401
    end
  end

  describe '#description' do
    it 'should be "Not Authorized"' do
      Sidewalk::NotAuthorizedError.new.description(nil).should == 'Not Authorized'
    end
  end
end
