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

require 'sidewalk/controller'

class NotARealController
end

class HelloController < Sidewalk::Controller
  def response
    'Hello, World!'
  end
end

class OpenController < Sidewalk::Controller
  attr_accessor :responder
  attr_reader :app_uri
  def response
    responder.call
  end

  def set_uri path, query = {}
    self.responder = lambda do
      @app_uri = Sidewalk::AppUri.new(path, query)
    end
  end

  def call_uri path, query = {}
    self.set_uri path, query
    self.call
    self.app_uri
  end
end
