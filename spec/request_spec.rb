require 'spec_helper'
require 'sidewalk/request'
require 'yaml'

describe Sidewalk::Request do
  before :each do
    @env = YAML.load(read_data_file('request_spec_1.yaml'))
    @match = Sidewalk::UriMatch.new(
      [:a, :b],
      {'foo' => :bar},
      :my_controller
    )
    @env['rack.input'] = StringIO.new
    @env['sidewalk.urimatch'] = @match
    @req = Sidewalk::Request.new(@env)
  end

  describe '#initialize' do
    it 'can\'t be called without arguments' do
      lambda do
        Sidewalk::Request.new
      end.should raise_error(ArgumentError)
    end

    it "can't be called with an arbitrary hash" do
      lambda do
        Sidewalk::Request.new({'foo' => 'bar'})
      end.should raise_error(ArgumentError)
    end

    it "can be called with a Rack environment variable" do
      lambda do
        Sidewalk::Request.new @env
      end.should_not raise_error
    end

    it "screams and dies if it doesn't recognize the rack version" do
      @env['rack.version'] = [2,0]
      lambda do
        Sidewalk::Request.new @env
      end.should raise_error
    end
    
    it "screams and dies if the protocol doesn't make sense" do
      @env['rack.url_scheme'] = 'gopher'
      lambda do
        Sidewalk::Request.new @env
      end.should raise_error
    end
  end

  describe '#root_uri' do
    it 'should return a URI::HTTP' do
      @req.root_uri.should be_a URI::HTTP
    end

    it 'should point at the root of the app' do
      @req.root_uri.to_s.should == 'http://localhost:9292/'
    end
  end

  describe '#request_uri' do
    it 'should return a URI::HTTP' do
      @req.request_uri.should be_a URI::HTTP
    end

    it 'should include the full URI with query string' do
      full = 'http://localhost:9292/foo/bar?baz'
      @req.request_uri.to_s.should == full
    end
  end

  describe '#secure?' do
    it 'should return false for HTTP' do
      @req.secure?.should be_false
    end

    it 'should return true for HTTPS' do
      @env['rack.url_scheme'] = 'https'
      Sidewalk::Request.new(@env).secure?.should be_true
    end
  end

  describe '#uri_match' do
    it 'should return the sidewalk.urimatch env' do
      @req.uri_match.should == @match
    end
  end

  describe '#uri_params' do
    it 'should return the parameters from the UriMatch' do
      @req.uri_params['foo'].should == :bar
    end
  end

  describe '#get_params' do
    it 'should return the parameters in the query string' do
      @req.get_params.should include 'baz'
    end
  end

  describe '#post_params' do
    it 'should return an empty Hash if there is no POST data' do
      @req.post_params.should be_empty
    end

    it 'should contain any POST form data' do
      s = 'herpity=derpity&derp'
      @env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      @env['rack.input'] = StringIO.new(s)
      req = Sidewalk::Request.new(@env)
      req.post_params['herpity'].should == 'derpity'
      req.post_params.should include 'derp'
    end
  end

  describe '#params' do
    it 'should include uri params' do
      @req.params['foo'].should == :bar
    end

    it 'should include GET params' do
      @req.params.should include 'baz'
    end

    it 'should include POST parms' do
      s = 'herpity=derpity'
      @env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      @env['rack.input'] = StringIO.new(s)
      req = Sidewalk::Request.new(@env)
      req.params['herpity'].should == 'derpity'
    end
  end
end
