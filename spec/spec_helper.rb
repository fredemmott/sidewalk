require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/sidewalk/regexp.rb' # 1.8 vs 1.9
end

def read_data_file(name)
  specs_dir = File.expand_path(File.dirname(__FILE__))
  path = File.join(specs_dir, 'data', name)
  File.read(path)
end
