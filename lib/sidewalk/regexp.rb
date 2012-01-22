module Sidewalk
  USING_ONIGURUMA = RUBY_VERSION.start_with?('1.8.')
  if USING_ONIGURUMA
    require 'oniguruma'
    Regexp = ::Oniguruma::ORegexp
  else
    Regexp = ::Regexp
  end
end
