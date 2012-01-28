require 'spec_helper'

require 'sidewalk/application'
require 'sidewalk/controller'

describe Sidewalk::Application do
  describe '.local_root' do
    it 'should return the working directory' do
      value = File.expand_path(Sidewalk::Application.local_root)
      value.should == File.expand_path('.')
    end

    it 'should give an absolute path' do
      value = Sidewalk::Application.local_root
      value.should == File.expand_path(value)
    end
  end

  context 'when constructed with a uri-map hash' do
    before :each do
      @input = {
        'herpity$' => :derpity,
      }
      @app = Sidewalk::Application.new(@input)
    end

    it 'should construct a UriMapper' do
      @app.mapper.should be_a Sidewalk::UriMapper
    end

    it 'should have used the map specified' do
      mapped = @app.mapper.map('herpity')
      mapped.should be
      mapped.controller.should == :derpity
    end

  end

  describe '#call' do
    before :each do
      @request, @logger = nil, nil
      @proc_responder = lambda{ |*args| @request, @logger = *args; :herp }
      @uri_map = {
        'class' => HelloController,
        'proc' => @proc_responder,
        'not_found' => lambda{ |*args| raise Sidewalk::NotFoundError.new },
        'permanent_redirect' => lambda { |*args|
          raise Sidewalk::PermanentRedirect.new(
            'http://www.example.com/permanent_redirect'
          )
        },
      }
      @app = Sidewalk::Application.new(@uri_map)
    end

    it 'should support class responders' do
      env = create_rack_env('PATH_INFO' => '/class')
      status, headers, body = @app.call(env)
      status.should == 200
      body.join('').should == 'Hello, World!'
    end

    it 'should support Proc responders' do
      env = create_rack_env('PATH_INFO' => '/proc')
      @app.call(env).should == :herp
    end

    it 'should have passed the UriMatch to the Request' do
      env = create_rack_env('PATH_INFO' => '/proc')
      @app.call(env)

      @request.uri_match.should be
      @request.uri_match.parameters.should be_empty
      @request.uri_match.controller.should be @proc_responder
      @request.uri_match.parts.should == ['proc']
    end

    it 'should return a status of 404 when given an invalid path' do
      env = create_rack_env('PATH_INFO' => '/not_in_the_map')
      status, headers, parts = @app.call(env)
      status.should == 404
    end

    context 'when a NotFoundError is raised' do
      it 'should give a status of 404' do
        env = create_rack_env('PATH_INFO' => '/not_found')
        status, *junk = @app.call(env)
        status.should == 404
      end

      it 'should look like a Rack response' do
        env = create_rack_env('PATH_INFO' => '/not_found')
        status, headers, body = @app.call(env)
        status.should be_a Fixnum
        headers.should be_a Hash
        headers.should include 'Content-Type'
        body.should respond_to :each
        body.each.first.should be_a String
      end
    end

    context 'when a PermanentRedirect is raised' do
      before :each do
        env = create_rack_env('PATH_INFO' => '/permanent_redirect')
        @status, @headers, @body = @app.call(env)
      end

      it 'should give a status of 301' do
        @status.should == 301
      end

      it 'should specify the correct location' do
        @headers.should include 'Location'
        @headers['Location'].should == 'http://www.example.com/permanent_redirect'
      end

      it 'should look like a Rack response' do
        @status.should be_a Fixnum
        @headers.should be_a Hash
        @headers.should include 'Content-Type'
        @body.should respond_to :each
        @body.each.first.should be_a String
      end
    end
  end
end
