require 'yaml'

module Sidewalk
  autoload :Application, 'sidewalk/application'

  # Class for storing application configuration.
  #
  # This will:
  # * load +config/environment.rb+ (arbitrary Ruby)
  # * read +config/environment.yaml+ into a +Hash+
  # * the same for +config/#{ENV['RACK_ENV']}.rb+ and +.yaml+
  #
  # @example environment.yaml
  #   activerecord:
  #     adapter: sqlite
  #     database: data.sqlite
  #
  # @example Reading from {Sidewalk::Config}
  #   ActiveRecord::Base.establish_connection(
  #     Sidewalk::Config['activerecord']
  #   )
  class Config
    # Initialize a Config object at the given path.
    #
    # You probably want to use the class methods instead.
    def initialize path
      @config = Hash.new
      @root = path
      [
        'environment.rb',
        "#{Config.environment}.rb",
      ].each{|x| load_ruby!(x, :silent => true)}

      yaml_configs = [
        'environment.yaml',
        "#{Config.environment}.yaml",
      ].each{|x| load_yaml!(x, :silent => true)}
    end

    # Return a configuration value from YAML.
    #
    # Acts like a +Hash+. Also available as a class method.
    #
    # @param [String] key
    def [] key
      @config[key]
    end

    # Store a configuration value, as if it were in the YAML.
    #
    # Also available as a class method.
    #
    # @param [String] key
    # @param [Object] value
    def []= key, value
      @config[key] = value
    end

    # Execute a Ruby file.
    #
    # Nothing special is done, it's just evaluated.
    #
    # Also available as a class method.
    #
    # @raise [LoadError] if +file+ does not exist, unless +:silent+ is set
    #   to true in +options+.
    # @param [String] file the path to the file, relative to the base
    #   configuration path.
    # @param [Hash] options
    def load_ruby! file, options = {}
      path = File.join(@root, file)
      begin
        load path
      rescue LoadError
        raise unless options[:silent]
      end
    end

    # Read a YAML file, and merge with the current config.
    #
    # This is available via {#[]}
    #
    # Also available as a class method.
    #
    # @raise [LoadError] if +file+ does not exist, unless +:silent+ is set
    #   to true in +options+.
    # @param [String] file the path to the file, relative to the base
    #   configuration path.
    # @param [Hash] options
    def load_yaml! file, options = {}
      path = File.join(@root, file)
      if File.exists? path
        @config.merge! YAML.load(File.read(path))
      else
        unless options[:silent]
          raise LoadError.new("unable to find #{file}")
        end
      end
    end

    class<<self
      # The main instance of {Config}.
      #
      # You probably don't want to use this - all of the methods defined on
      # instances are usable as class methods instead, that map onto the
      # instance.
      #
      # @return [Config] an instance of {Config}
      def instance
        @instance ||= Config.new(self.path)
      end
      alias :init! :instance

      # Where to look for configuration files.
      #
      # This defaults to +config/+ underneath the application root.
      def path
        @path ||= Application.local_root + '/config'
      end
      attr_writer :path

      # What the current Rack environment is.
      #
      # This is an arbitrary string, but will usually be:
      # production:: this is live, probably via Passenger
      # development:: running on a developer's local machine, probably via
      #   +rackup+ or +shotgun+
      # testing:: automated tests are running.
      #
      # This is copied from +ENV['RACK_ENV']+, but can be overridden (see
      # {#environment=}).
      def environment
        @environment ||= ENV['RACK_ENV'] || raise("Unable to determine environment. Set ENV['RACK_ENV'].")
      end

      # Override the auto-detected environment.
      #
      # Handy for testing - especially as RACK_ENV might not even be set.
      def environment= foo
        @environment = foo
      end

      def production?
        self.environment == 'production'
      end

      def development?
        self.environment == 'development'
      end

      def testing?
        self.environment == 'testing'
      end

      %w{[] []= load_ruby! load_yaml!}.map(&:to_sym).each do |method|
        define_method(method, lambda{ |*args| instance.send(method, *args)})
      end
    end
  end
end
