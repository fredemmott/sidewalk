module Sidewalk
  class UriMatch
    attr_reader :parts, :parameters, :controller
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
