[![build status](https://secure.travis-ci.org/fredemmott/sidewalk.png)](http://travis-ci.org/fredemmott/sidewalk) [![dependency status](https://gemnasium.com/fredemmott/sidewalk.png)](https://gemnasium.com/fredemmott/sidewalk)

Is this usable?
===============

I'm not aware of anyone (including myself) using it in production yet. Here
be dragons.

What is this?
=============

A lightweight web framework for Ruby, heavily influenced by
[Aphront](https://github.com/facebook/phabricator/tree/master/src/aphront).

There are 3 main components to a Sidewalk application:

* Several Controllers
* The Application
* A URI-map; this is a hash where the keys are Strings containing regexp
  patterns, and the values are Controller classes, or their names
  (Strings or Symbols).

URI's are mapped from String regexp patterns to make things more
compatible between Ruby 1.8 and Ruby 1.9; under 1.9, this is mapped on to
the standard Regexp class, but in 1.8, Sidewalk depends on Oniguruma
and uses that instead.

Hello, World
============

In the form of a 'config.ru':

````ruby
require 'sidewalk'

class HelloController < Sidewalk::Controller
  def response
    "Hello, world."
  end
end

urimap = {
  '$' => :HelloController,
}

run Sidewalk::Application.new(urimap)
````

Sidewalk::ControllerMixins::ViewTemplates provides a #render method that
acts like you expect, and you're probably also interested in
Sidewalk::Request and Sidewalk::Controller.

What about variables in the URLs?
=================================

Use standard named captures - for example, this provides an 'id' parameter

````ruby
urimap = {
  '$' => :IndexController,
  'posts/' => {
    '$' => :PostsController,
    '(?<id>\d+)$' => :PostController,
  }
}
````

What's different compared to Rails?
===================================

Some major differences compared to Rails:

* There's much less of it. This has its' good sides, but it also means
  less features.
* There is no standard layout for URLs - it's entirely up to you.
* Each controller deals with one kind of page. This is by comparison to the
  same controller class being responsible for both /foo/ and /foo/123
* Parameters in the url are standard named regular expression captures - no
  custom syntax.
* By default, there's no explicit view support - include
  Sidewalk::ControllerMixins::ViewTemplates to get support for ERB, HAML,
  and RXhp - and it's easy to add support for other languages.

There is little magic, and you don't need to use it:

* Sidewalk will automatically load config/environment.rb and
  config/production|testing|development.rb as appropriate
* It will also load any similarly-named .yaml files into the
  Sidewalk::Config hash
* If you put 'FooController' in your URI-map, but don't require, Sidewalk
  will look for it in controllers/
