
module MybokaHelpers
  module Config
    class << self
      def config(config)
        @config = config
      end

      def [](key)
        raise 'please set Configurations first' unless @config
        @config[key]
      end
    end
  end
end