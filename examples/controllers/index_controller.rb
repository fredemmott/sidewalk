require 'sidewalk/controller_mixins/view_templates'

require 'erb'

class IndexController < Sidewalk::Controller
  # If this was a real app, you'd probably do these includes in your
  # ApplicationController or similar:

  # Look for views/foo.bar, render it with BarHandler.
  include Sidewalk::ControllerMixins::ViewTemplates
  # We're using ERB for this example as everyone knows it, and it ships
  # with Ruby. If you're using ERB, you probably want to pull in
  # #html_escape (aka #h) and friends.
  include ERB::Util

  # Actually return some content
  def payload
    @links = {
      'Hello, world' => relative_uri('hello'),
    }
    render
  end
end
