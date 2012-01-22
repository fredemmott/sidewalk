require 'spec_helper'
require 'sidewalk/regexp'

describe Sidewalk::Regexp do
  it 'should support named capture' do
    reg = Sidewalk::Regexp.new('foo(?<bar>\d+)baz')
    match = reg.match 'foo123baz'
    match[:bar].should == '123'
  end

  it 'should support listing names' do
    reg = Sidewalk::Regexp.new('foo(?<bar>\d+)baz')
    match = reg.match 'foo123baz'
    match.names.should include 'bar'
  end

  it 'should support #post_match' do
    reg = Sidewalk::Regexp.new('herpity')
    match = reg.match 'herpity derpity'
    match.post_match.should == ' derpity'
  end

  it 'should support trivial matches' do
    (Sidewalk::Regexp.new('foo') =~ 'foo').should == 0
  end

  it 'should support trivial non-matches' do
    (Sidewalk::Regexp.new('foo') =~ 'bar').should be_nil
  end
end
