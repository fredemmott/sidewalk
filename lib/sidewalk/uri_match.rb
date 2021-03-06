module Sidewalk
  # Information on a +URI+ +=>+ {Controller} match.
  #
  # These are generated by {UriMapper}.
  class UriMatch
    # The URL path, divided into regexp-matches.
    #
    # The URI map is a tree; this tells you what was matched at each level
    # of the tree.
    attr_reader :parts

    # Any named captures from the match.
    attr_reader :parameters

    # What the URL maps to.
    #
    # This should be an instance of {Controller}, or a +Proc+.
    attr_reader :controller

    def initialize parts = [], parameters = {}, controller = nil
      unless parts.is_a?(Array) && parameters.is_a?(Hash)
        raise ArgumentError.new(
          'Sidewalk::UriMatch([parts], {parameters}, controller)'
        )
      end
      @parts, @parameters, @controller = parts, parameters, controller
    end
  end
end
