require 'spec_helper'

require 'sidewalk/rooted_uri'

describe Sidewalk::RootedUri do
  describe '#new' do
    before :each do
      @root_string = 'https://www.example.com/foo/'
      @root_uri = URI.parse(@root_string)
    end


    it 'returns an appropriate URI subclass' do
      uri = Sidewalk::RootedUri.new(@root_uri, '/')
      uri.should be_a URI::HTTPS
    end

    it 'returns the root URI unmodified for /' do
      uri = Sidewalk::RootedUri.new(@root_uri, '/')
      uri.should == @root_uri
    end

    it 'returns a URI underneath the root uri when a path is given' do
      uri = Sidewalk::RootedUri.new(@root_uri, '/bar')
      uri.path.should == '/foo/bar'
    end

    it 'does not append an empty query string' do
      uri = Sidewalk::RootedUri.new(@root_uri, '/bar')
      uri.to_s.should_not include '?'
    end

    it 'includes query parameters' do
      Sidewalk::RootedUri.new(
        @root_uri,
        '/bar',
        'foo' => 'bar'
      ).query.should == 'foo=bar'
    end

    it 'escapes query values' do
      Sidewalk::RootedUri.new(
        @root_uri,
        '/bar',
        'foo&bar' => 'herp&derp'
      ).query.should == 'foo%26bar=herp%26derp'
    end
  end
end
