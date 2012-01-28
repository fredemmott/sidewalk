require 'spec_helper'

require 'sidewalk/redirect'

describe Sidewalk::SeeOtherRedirect do
  before :each do
    @url = URI.parse('http://www.example.com/')
    @url.path = '/' + rand.to_s

    @redirect = Sidewalk::SeeOtherRedirect.new(@url)
    @env = create_rack_env
  end

  it 'is a Sidewalk::Redirect' do
    @redirect.is_a?(Sidewalk::Redirect).should be_true
  end

  describe '#url' do
    it 'returns the URL passed to the constructor' do
      @redirect.url.should == @url
    end
  end

  context 'with a HTTP/1.0 request' do
    before :each do
      @env['HTTP_VERSION'] = 'HTTP/1.0'
      @env['SERVER_PROTOCOL'] = 'HTTP/1.0'
      @req = Sidewalk::Request.new(@env)
    end

    describe '#status' do
      it 'returns 302' do
        @redirect.status(@req).should == 302
      end
    end

    describe '#description' do
      it 'returns "Found"' do
        @redirect.description(@req).should == 'Found'
      end
    end
  end

  context 'with a HTTP/1.1 request' do
    before :each do
      @req = Sidewalk::Request.new(@env)
    end

    describe '#status' do
      it 'returns 303' do
        @redirect.status(@req).should == 303
      end
    end
    
    describe '#description' do
      it 'returns "See Other"' do
        @redirect.description(@req).should == 'See Other'
      end
    end

  end
end
