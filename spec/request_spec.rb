require 'spec_helper'
require 'sidewalk/request'

describe Sidewalk::Request do
  before :each do
    @match = Sidewalk::UriMatch.new(
      [:a, :b],
      {'foo' => :bar},
      :my_controller
    )
    @env = create_rack_env('sidewalk.urimatch' => @match)
    @req = Sidewalk::Request.new(@env)
  end

  describe '#headers' do
    it 'returns some headers' do
      @req.headers.should_not be_empty
    end

    it 'only returns HTTP headers' do
      @req.headers.all?{|k,v| k.start_with? 'HTTP_'}.should be_true
    end
  end

  describe '#cookies' do
    it 'should be a Hash' do
      @req.cookies.should be_a Hash
    end

    it 'should be empty if there were no cookie headers' do
      @req.cookies.should be_empty
    end

    it 'should set an Array set-cookie header' do
      @env['HTTP_COOKIE'] = 'foo=bar; herp=derp'
      req = Sidewalk::Request.new(@env)
      req.cookies.should include 'foo'
      req.cookies['foo'].should == 'bar'
      req.cookies.should include 'herp'
      req.cookies['herp'].should == 'derp'
    end
  end

  describe '#http_version' do
    it 'returns "1.1" for HTTP/1.1 requests' do
      @req.http_version.should == '1.1'
    end

    it 'returns "1.0" for HTTP/1.0 requests' do
      @env['HTTP_VERSION'] = 'HTTP/1.0'
      @env['SERVER_PROTOCOL'] = 'HTTP/1.0'
      req = Sidewalk::Request.new(@env)
      req.http_version.should == '1.0'
    end

    it 'should return nil if no version was specified' do
      @env.delete 'HTTP_VERSION'
      @env.delete 'SERVER_PROTOCOL'
      req = Sidewalk::Request.new(@env)
      req.http_version.should be_nil
    end

    it 'should work with just SERVER_PROTOCOL' do
      @env.delete 'SERVER_PROTOCOL'
      req = Sidewalk::Request.new(@env)
      req.http_version.should == '1.1'
    end

    it 'should work with just HTTP_VERSION' do
      @env.delete 'SERVER_PROTOCOL'
      req = Sidewalk::Request.new(@env)
      req.http_version.should == '1.1'
    end
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

    it 'should return a duplicate' do
      @req.root_uri.should_not equal @req.root_uri
    end
  end

  describe '#uri' do
    it 'should return a URI::HTTP' do
      @req.uri.should be_a URI::HTTP
    end

    it 'should include the full URI with query string' do
      full = 'http://localhost:9292/foo/bar?baz'
      @req.uri.to_s.should == full
    end

    it 'should return a duplicate' do
      @req.uri.should_not equal @req.uri
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
