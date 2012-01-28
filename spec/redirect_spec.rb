require 'spec_helper'

require 'sidewalk/redirect'
require 'uri'

describe Sidewalk::Redirect do
  describe '#url' do
    it 'normalizes URIs to Strings' do
      uri = URI.parse('https://www.example.com')
      Sidewalk::Redirect.new(uri, nil, nil).url.should be_a String
    end
  end
end
