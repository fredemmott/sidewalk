require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/sidewalk/regexp.rb' # 1.8 vs 1.9
end
