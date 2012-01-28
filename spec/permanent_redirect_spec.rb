require 'spec_helper'

require 'sidewalk/redirect'

describe Sidewalk::PermanentRedirect do
  before :each do
    @url = URI.parse('http://www.example.com/')
    @url.path = '/' + rand.to_s

    @redirect = Sidewalk::PermanentRedirect.new(@url)
  end

  it 'is a Sidewalk::Redirect' do
    @redirect.is_a?(Sidewalk::Redirect).should be_true
  end

  describe '#url' do
    it 'returns the URL passed to the constructor' do
      @redirect.url.to_s.should == @url.to_s
    end
  end

  describe '#status' do
    it 'returns 301' do
      @redirect.status(nil).should == 301
    end
  end

  describe '#description' do
    it 'returns "Moved Permanently"' do
      @redirect.description(nil).should == 'Moved Permanently'
    end
  end
end
