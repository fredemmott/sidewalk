module Sidewalk
  module Oniguruma
    module MatchData
      def names
        if @named_captures
          @named_captures.keys.map(&:to_s)
        else
          []
        end
      end
    end
  end

  REGEXP_USING_ONIGURUMA = RUBY_VERSION.start_with?('1.8.')
  if REGEXP_USING_ONIGURUMA
    require 'oniguruma'
    REGEXP_BASE = ::Oniguruma::ORegexp
    ::MatchData.send(:include, Sidewalk::Oniguruma::MatchData)
  else
    REGEXP_BASE = ::Regexp
  end

  # A Regexp class that supports named captures.
  #
  # This class exists just to give a portable class name to refer to.
  #
  # * On Ruby 1.9, this inherits +::Regexp+.
  # * On Ruby 1.8, this inherits +Oniguruma::ORegexp+ (which is basically
  #   the same library that Ruby 1.9 uses for +::Regexp+)
  #
  # @example Using named captures
  #   regexp = Sidewalk::Regexp.new('(?<foo>bar)')
  #   match = regexp.match(regexp)
  #   match['foo'].should == 'bar'
  class Regexp < REGEXP_BASE
    # Whether we're using +Onigirumua::ORegexp+.
    #
    # Inverse of {#native?}.
    def self.oniguruma?
      Sidewalk::REGEXP_USING_ONIGURUMA
    end

    # Whether we're using +::Regexp+
    #
    # Inverse of {#native?}.
    def self.native?
      !self.oniguruma?
    end
  end
end
