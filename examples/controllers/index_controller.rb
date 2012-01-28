require 'sidewalk/controller_mixins/view_templates'
require 'sidewalk/app_uri'

class IndexController < Sidewalk::Controller
  # If this was a real app, you'd probably do this include in your
  # ApplicationController or similar:
  # Look for views/foo.bar, render it with BarHandler.
  include Sidewalk::ControllerMixins::ViewTemplates

  # Actually return some content
  def response
    @links = {
      'Hello, world' => Sidewalk::AppUri.new('/hello'),
    }
    render
  end
end
