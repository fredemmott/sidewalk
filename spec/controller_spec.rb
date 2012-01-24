require 'sidewalk/controller'

describe Sidewalk::Controller do
  describe '#payload' do
    it 'raises a NotImplementedError' do
      lambda{
        Sidewalk::Controller.new(nil,nil).payload
      }.should raise_error(NotImplementedError)
    end
  end

  describe '#relative_uri' do
    it 'gives a path relative to the request uri' do
      uri = URI.parse('http://www.example.com/foo/')

      request = Object.new
      request.should_receive(:uri).and_return(uri)
      
      result = Sidewalk::Controller.new(request, nil).relative_uri('bar')
      result.should == URI.parse('http://www.example.com/foo/bar')
    end
  end

  describe '#call' do
    before :each do
      @payload = rand.to_s
      @controller = Sidewalk::Controller.new(nil, nil)
      class <<@controller
        attr_accessor :payload
      end
      @controller.payload = @payload
    end

    it 'should call #payload' do
      @controller.should_receive(:payload).and_return(@payload)
      @controller.call
    end

    it 'should give a 200 status by default' do
      status, headers, body = @controller.call
      status.should == 200
    end

    it 'should have a default content-type of text/html' do
      status, headers, body = @controller.call
      headers.should include 'Content-Type'
      headers['Content-Type'].should == 'text/html'
    end

    it 'should return the result of #payload as the only content' do
      status, headers, body = @controller.call
      body.should == [@payload]
    end
  end

  describe '.current' do
    it 'should return nil if not called from #payload' do
      Sidewalk::Controller.current.should be_nil
    end

    it 'should return the controller if called from #payload' do
      it = Sidewalk::Controller.new(nil, nil)
      class <<it
        attr_accessor :current
        def payload
          self.current = Sidewalk::Controller.current
        end
      end
      it.call
      it.current.should == it
    end

    context 'with two controllers active in the same thread' do
      it 'should return the correct one from #payload' do
        outer = Sidewalk::Controller.new(nil, nil)
        class <<outer
          attr_accessor :inner
          attr_accessor :pre
          attr_accessor :post
          def payload
            self.pre = Sidewalk::Controller.current
            inner.call
            self.post = Sidewalk::Controller.current
          end
        end
        inner = Sidewalk::Controller.new(nil, nil)
        class <<inner
          attr_accessor :current
          def payload
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
