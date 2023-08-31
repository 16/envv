# frozen_string_literal: true

require "dry-initializer"
require "dry/schema"

module ENVV
  class Builder
    extend Dry::Initializer

    option :schema
    option :env

    def call!
      raise InvalidSchemaError unless schema.is_a?(::Dry::Schema::Params)
      raise InvalidEnvError unless env.is_a?(::Enumerable)

      keys = @schema.key_map.map { |key| key.name }
      env_vars = @env.select { |name, value| keys.include?(name) }
      result = @schema.call(env_vars)
      if result.failure?
        raise ValidationError, result.errors(full: true).to_h.values.flatten
      else
        ENVV::Registry.instance.replace result.to_h.transform_keys(&:to_s)
      end
    end
  end
end
