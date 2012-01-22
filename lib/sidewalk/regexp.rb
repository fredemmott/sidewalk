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

  USING_ONIGURUMA = RUBY_VERSION.start_with?('1.8.')
  if USING_ONIGURUMA
    require 'oniguruma'
    Regexp = ::Oniguruma::ORegexp

    ::MatchData.send(:include, Sidewalk::Oniguruma::MatchData)
  else
    Regexp = ::Regexp
  end
end
