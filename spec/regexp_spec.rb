require 'spec_helper'
require 'sidewalk/regexp'

describe Sidewalk::Regexp do
  it 'supports named captures' do
    reg = Sidewalk::Regexp.new('foo(?<bar>\d+)baz')
    match = reg.match 'foo123baz'
    match[:bar].should == '123'
  end

  it 'supports #post_match' do
    reg = Sidewalk::Regexp.new('herpity')
    match = reg.match 'herpity derpity'
    match.post_match.should == ' derpity'
  end

  it 'supports trivial matches' do
    (Sidewalk::Regexp.new('foo') =~ 'foo').should == 0
  end

  it 'supports trivial non-matches' do
    (Sidewalk::Regexp.new('foo') =~ 'bar').should be_nil
  end
end
