require 'yaml'

def read_data_file(name)
  specs_dir = File.expand_path(File.dirname(__FILE__))
  path = File.join(specs_dir, 'data', name)
  File.read(path)
end

def create_rack_env overrides = {}
  env = YAML.load(read_data_file('request_spec_1.yaml'))
  env['rack.input'] = StringIO.new
  env.merge(overrides)
end

unless RUBY_VERSION.start_with? '1.8.'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/lib/sidewalk/regexp.rb' # 1.8 vs 1.9
  end
end
