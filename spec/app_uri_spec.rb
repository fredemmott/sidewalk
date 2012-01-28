require 'spec_helper'

require 'sidewalk/app_uri'

class BogusController < Sidewalk::Controller
  attr_accessor :responder
  attr_reader :app_uri
  def response
    responder.call
  end

  def set_uri path, query = {}
    self.responder = lambda do
      @app_uri = Sidewalk::AppUri.new(path, query)
    end
  end

  def call_uri path, query = {}
    self.set_uri path, query
    self.call
    self.app_uri
  end
end

describe Sidewalk::AppUri do
  describe '#new' do
    it 'bails if it\'s not being called as part of a response' do
      lambda{Sidewalk::AppUri.new '/foo'}.should raise_error
    end

    context 'from Controller#response' do
      before :each do
        @root_uri_string = 'https://www.example.com/foo/'
        root_uri = URI.parse(@root_uri_string)
        @root_uri = root_uri

        request = Class.new.new
        request.class.send(:define_method, :root_uri, lambda{root_uri})

        @controller = BogusController.new(request, nil)
      end

      it 'doesn\'t raise an error' do
        @controller.set_uri '/'
        lambda{@controller.call}.should_not raise_error
      end

      it 'returns an appropriate URI subclass' do
        @controller.call_uri('/').should be_a URI::HTTPS
      end

      it 'returns the root URI unmodified for /' do
        @controller.call_uri('/').should == @root_uri
      end

      it 'returns a URI underneath the root uri when a path is given' do
        @controller.call_uri('/bar').path.should == '/foo/bar'
      end

      it 'does not append an empty query string' do
        @controller.call_uri('/bar').to_s.should_not include '?'
      end

      it 'includes query parameters' do
        @controller.call_uri(
          '/bar',
          'foo' => 'bar'
        ).query.should == 'foo=bar'
      end

      it 'escapes query values' do
        @controller.call_uri(
          '/bar',
          'foo&bar' => 'herp&derp'
        ).query.should == 'foo%26bar=herp%26derp'
      end
    end
  end
end
