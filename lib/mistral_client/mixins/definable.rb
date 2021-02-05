module MistralClient
  module Mixins
    module Definable
      # rubocop:disable Metrics/MethodLength
      def parse_definition(definition)
        if definition.is_a?(Hash) || definition.is_a?(Array)
          return YAML.dump(definition)
        end

        definition = File.read(definition) if File.exist?(definition)
        # Called outside the if/else to validate the YAML.
        parsed = YAML.safe_load(definition, aliases: true)
        if defined? massage_definition
          massage_definition(parsed)
        else
          definition
        end
      rescue Psych::SyntaxError
        raise ConfigurationError,
              'Only filenames or raw or parsed strings of YAML are supported.'
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
