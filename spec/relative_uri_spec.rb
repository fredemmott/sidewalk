require 'spec_helper'

require 'sidewalk/relative_uri'

describe Sidewalk::RelativeUri do
  describe '#new' do
    it 'bails if it\'s not being called as part of a response' do
      lambda{Sidewalk::RelativeUri.new '/foo'}.should raise_error
    end

    context 'from Controller#response' do
      before :each do
        root_uri_string = 'https://www.example.com/foo/'
        root_uri = URI.parse(root_uri_string)
        @request_uri_string = root_uri_string + 'bar'
        request_uri = URI.parse(@request_uri_string)
        @request_uri = request_uri

        request = Class.new.new
        request.class.send(:define_method, :root_uri, lambda{root_uri})
        request.class.send(:define_method, :uri, lambda{request_uri})

        @controller = OpenController.new(request, nil)
        @controller.uri_klass = Sidewalk::RelativeUri
      end

      it 'doesn\'t raise an error' do
        @controller.set_uri '/'
        @controller.uri_klass = Sidewalk::RelativeUri
        lambda{@controller.call}.should_not raise_error
      end

      it 'returns the request uri for /' do
        @controller.call_uri('/').path.should == '/foo/bar/'
      end

      it 'returns a URI underneath the request uri when a path is given' do
        @controller.call_uri('/baz').path.should == '/foo/bar/baz'
      end
    end
  end
end
