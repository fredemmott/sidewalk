$LOAD_PATH.push File.expand_path('../lib')
require 'sidewalk'

urimap = {
  '$' => :IndexController,
  'hello$' => :HelloController,
}

run Sidewalk::Application.new(urimap)
