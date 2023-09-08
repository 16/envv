# frozen_string_literal: true

require "dry-initializer"
require "dry/schema"

module ENVV
  class Builder
    attr_reader :env, :schema

    class << self
      def call(env, schema = nil)
        new(env, schema).call
      end

      def to_proc
        method(:call).to_proc
      end
    end

    def initialize(env, schema)
      @env = env
      @schema = schema
    end

    def call
      validate_params!
      result = @schema.call(extract_env_vars)

      if result.failure?
        raise ValidationError, result.errors(full: true).to_h.values.flatten
      else
        ENVV::Registry[result.to_h.transform_keys(&:to_s)].freeze
      end
    end

    private

    def validate_params!
      raise InvalidSchemaError unless schema.is_a?(::Dry::Schema::Params)
      raise InvalidEnvError unless env.is_a?(::Enumerable)
    end

    def extract_env_vars
      keys = @schema.key_map.map { |key| key.name }
      @env.select { |name, value| keys.include?(name) }
    end
  end
end
