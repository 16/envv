# frozen_string_literal: true

module ENVV
  class Builder
    attr_reader :schema, :env

    def initialize(schema:, env:)
      @schema = schema
      @env = env
    end

    def call!
      unless schema.is_a? ::Dry::Schema::Params
        raise InvalidSchemaError
      end

      unless env.is_a? ::Enumerable
        raise InvalidEnvError
      end

      keys = @schema.key_map.map { |key| key.name }
      env_vars = @env.select { |name, value| keys.include?(name) }
      result = @schema.call(env_vars)
      if result.failure?
        raise ValidationError
      else
        ENVV::Registry.instance.replace result.to_h.transform_keys(&:to_s)
      end
    end
  end
end