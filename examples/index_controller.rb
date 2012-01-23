require 'rxhp'

class IndexController < Sidewalk::Controller
  include Rxhp::Html
  def content
    rows = {
      'hello' => 'Hello example',
    }.map do |path, text|
      uri = request.root_uri
      uri.path += path

      li do
        a(text, :href => uri)
      end
    end

    html do
      head do
        title 'Sidewalk Examples'
      end
      body do
        ul do
          fragment rows
        end
      end
    end.render
  end
end
