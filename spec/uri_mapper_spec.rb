require 'spec_helper'
require 'sidewalk/uri_mapper'

class FooController
end

describe Sidewalk::UriMapper do
  it 'can be default-constructed' do
    lambda { Sidewalk::UriMapper.new }.should_not raise_error
  end

  it 'should accept a hash' do
    lambda{ Sidewalk::UriMapper.new({'/' => Object})}.should_not raise_error
  end

  it 'should raise an ArgumentError if given a map with a RegExp key' do
    lambda do
      Sidewalk::UriMapper.new(/.+/ => Object)
    end.should raise_error(ArgumentError)
  end

  it 'should raise an ArgumentError if given a sub-map with a RegExp key' do
    # It's converted to a Sidewalk::Regexp in the background, as Regexp in
    # Ruby 1.8 does not support named captures.
    lambda do
      Sidewalk::UriMapper.new({'' => {/.+/ => Object}})
    end.should raise_error(ArgumentError)
  end

  it 'requires it\'s argument to be a Hash' do
    lambda do
      Sidewalk::UriMapper.new(Object.new)
    end.should raise_error ArgumentError
  end

  describe '#map' do
    context 'with just the root path defined' do
      before :each do
        @root = 'a stub'
        map = {
          '$' => @root,
        }
        @mapper = Sidewalk::UriMapper.new(map)
      end

      it 'can map the root path' do
        @mapper.map('').should be
      end

      it 'returns a UriMatch object' do
        @mapper.map('').should be_a Sidewalk::UriMatch
      end

      it 'returns a UriMatch with the right controller' do
        @mapper.map('').controller.should be @root
      end

      it 'will not map an arbitrary path' do
        @mapper.map('foo').should_not be
      end
    end

    context 'with sub paths' do
      before :each do
        map = {
          '$' => :root,
          'foo' => {
            '$' => :child,
            '/bar' => :grandchild,
          },
          'herp' => :second_child,
        }
        @mapper = Sidewalk::UriMapper.new(map)
      end

      it 'should map the root path' do
        @mapper.map('').controller.should equal :root
      end

      it 'should map a non-root path with child paths defined' do
        @mapper.map('foo').controller.should equal :child
      end

      it 'should return the path matchers via the UriMatch object' do
        match = @mapper.map('foo/bar123')
        match.parts.should == ['foo', '/bar']
      end

      it 'should map a child path' do
        @mapper.map('foo/bar').controller.should equal :grandchild
      end

      it 'should map a root path with no children' do
        @mapper.map('herp').controller.should equal :second_child
      end

      it 'shouldn\t assume $' do
        match = @mapper.map('herpity')
        match.should be
        match.controller.should equal :second_child
      end
    end

    context 'with regular expressions' do
      before :each do
        map = {
          '\d+' => :numeric,
          '[a-z]+' => :text,
          'Articles/(?<id>\d+)$' => :capture,
        }
        @mapper = Sidewalk::UriMapper.new(map)
      end

      it 'should match basic patterns' do
        @mapper.map('123').controller.should be :numeric
        @mapper.map('abc').controller.should be :text
      end

      it 'should give named captures as parameters' do
        match = @mapper.map('Articles/123')
        match.should be
        match.controller.should be :capture
        match.parameters[:id].to_s.should == '123'
      end
    end
  end

  it 'adds an implicit ^' do
    map = {
      '$' => nil,
      'foo' => nil,
      '^bar' => nil,
    }
    keys = Sidewalk::UriMapper.new(map).uri_map.keys.map(&:source)
    keys.should include '^$'
    keys.should include '^foo'
    keys.should include '^foo'
  end

  context 'autoloading' do
    it 'converts symbols to classes' do
      map = { '$' => :FooController }
      Sidewalk::UriMapper.new(map).uri_map.values.should include FooController
    end

    it 'attempts to require controller classes' do
      map = { '$' => :BarController }
      lambda do
        Sidewalk::UriMapper.new(map)
      end.should raise_error(LoadError)
    end
  end
end
