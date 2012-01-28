require 'spec_helper'
require 'sidewalk/errors'

describe Sidewalk::ForbiddenError do
  describe '#status' do
    it 'should be 403' do
      Sidewalk::ForbiddenError.new.status(nil).should == 403
    end
  end

  describe '#description' do
    it 'should be "Forbidden"' do
      Sidewalk::ForbiddenError.new.description(nil).should == 'Forbidden'
    end
  end
end
