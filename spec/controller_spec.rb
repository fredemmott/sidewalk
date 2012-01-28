require 'sidewalk/controller'

describe Sidewalk::Controller do
  describe '#response' do
    it 'raises a NotImplementedError' do
      lambda{
        Sidewalk::Controller.new(nil,nil).response
      }.should raise_error(NotImplementedError)
    end
  end

  describe '#headers' do
    it 'should include the Content-Type' do
      controller = Sidewalk::Controller.new(nil, nil)
      controller.headers.should include 'Content-Type'
      controller.headers['Content-Type'].should == 'text/html'
    end
  end

  describe '#set_cookie' do
    before :each do
      @controller = Sidewalk::Controller.new(nil, nil)
    end

    it 'sets a Set-Cookie header for a cookie' do
      @controller.set_cookie 'foo', 'bar'
      @controller.headers.should include 'Set-Cookie'
      @controller.headers['Set-Cookie'].should == 'foo=bar'
    end

    it 'sets a Set-Cookie header array for 2 cookies' do
      @controller.set_cookie 'foo', 'bar'
      @controller.set_cookie 'herp', 'derp'
      @controller.headers.should include 'Set-Cookie'
      @controller.headers['Set-Cookie'].should == "foo=bar\nherp=derp"
    end

    it 'has no default expiry' do
      @controller.set_cookie 'foo', 'bar'
      @controller.headers['Set-Cookie'].should == 'foo=bar'
    end

    it 'accepts a :domain option' do
      @controller.set_cookie('foo', 'bar', :domain => 'example.com')
      header = @controller.headers['Set-Cookie']
      header.should == 'foo=bar; domain=example.com'
    end

    it 'accepts a :path option' do
      @controller.set_cookie('foo', 'bar', :path => 'example.com')
      header = @controller.headers['Set-Cookie']
      header.should == 'foo=bar; path=example.com'
    end

    it 'accepts a :secure option' do
      @controller.set_cookie('foo', 'bar', :secure => true)
      header = @controller.headers['Set-Cookie']
      header.should == 'foo=bar; secure'
    end

    it 'accepts an :httponly option' do
      @controller.set_cookie('foo', 'bar', :httponly => true)
      header = @controller.headers['Set-Cookie']
      header.should == 'foo=bar; HttpOnly'
    end

    it 'accepts an :expires Time' do
      @controller.set_cookie('foo', 'bar', :expires => Time.at(1327789544))
      header = @controller.headers['Set-Cookie']
      header.should == 'foo=bar; expires=Sat, 28-Jan-2012 22:25:44 GMT'
    end

    it 'accepts any stringable value' do
      derp = Object.new
      def derp.to_s; 'derp'; end

      @controller.set_cookie('herp', derp)
      header = @controller.headers['Set-Cookie']
      header.should == 'herp=derp'
    end
  end

  describe '#call' do
    before :each do
      @response = rand.to_s
      @controller = Sidewalk::Controller.new(nil, nil)
      class <<@controller
        attr_accessor :response
      end
      @controller.response = @response
    end

    it 'should call #response' do
      @controller.should_receive(:response).and_return(@response)
      @controller.call
    end

    it 'should give a 200 status by default' do
      status, headers, body = @controller.call
      status.should == 200
    end

    it 'should return a different status code if overridden' do
      @controller.status = 404
      status, *junk = @controller.call
      status.should == 404
    end

    it 'should have a default content-type of text/html' do
      status, headers, body = @controller.call
      headers.should include 'Content-Type'
      headers['Content-Type'].should == 'text/html'
    end

    it 'should return a custom content-type if set' do
      @controller.content_type = 'text/plain'
      status, headers, body = @controller.call
      headers['Content-Type'].should == 'text/plain'
    end

    it 'should return the result of #response as the only content' do
      status, headers, body = @controller.call
      body.should == [@response]
    end
  end

  describe '.current' do
    it 'should return nil if not called from #response' do
      Sidewalk::Controller.current.should be_nil
    end

    it 'should return the controller if called from #response' do
      it = Sidewalk::Controller.new(nil, nil)
      class <<it
        attr_accessor :current
        def response
          self.current = Sidewalk::Controller.current
        end
      end
      it.call
      it.current.should == it
    end

    context 'with two controllers active in the same thread' do
      it 'should return the correct one from #response' do
        outer = Sidewalk::Controller.new(nil, nil)
        class <<outer
          attr_accessor :inner
          attr_accessor :pre
          attr_accessor :post
          def response
            self.pre = Sidewalk::Controller.current
            inner.call
            self.post = Sidewalk::Controller.current
          end
        end
        inner = Sidewalk::Controller.new(nil, nil)
        class <<inner
          attr_accessor :current
          def response
            self.current = Sidewalk::Controller.current
          end
        end
        outer.inner = inner
        outer.call

        outer.pre.should == outer
        outer.post.should == outer
        inner.current.should == inner
      end
    end
  end
end
