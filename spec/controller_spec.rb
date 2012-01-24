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

  describe '#response' do
    before :each do
      @payload = payload = rand.to_s
      @controller = Sidewalk::Controller.new(nil, nil)
      @controller.define_singleton_method(:payload){ payload }
    end

    it 'should call #payload' do
      @controller.should_receive(:payload).and_return(@payload)
      @controller.response
    end

    it 'should give a 200 status by default' do
      status, headers, body = @controller.response
      status.should == 200
    end

    it 'should have a default content-type of text/html' do
      status, headers, body = @controller.response
      headers.should include 'Content-Type'
      headers['Content-Type'].should == 'text/html'
    end

    it 'should return the result of #payload as the only content' do
      status, headers, body = @controller.response
      body.should == [@payload]
    end
  end
end
