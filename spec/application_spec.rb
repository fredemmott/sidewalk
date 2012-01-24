require 'spec_helper'

require 'sidewalk/application'
require 'sidewalk/controller'

class FooController < Sidewalk::Controller
  def payload
    'whee'
  end
end

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
        'class' => FooController,
        'proc' => @proc_responder,
      }
      @app = Sidewalk::Application.new(@uri_map)
    end

    it 'should support class responders' do
      env = create_rack_env('PATH_INFO' => '/class')
      status, headers, body = @app.call(env)
      status.should == 200
      body.join('').should == 'whee'
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
  end
end
