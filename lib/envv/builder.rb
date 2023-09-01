# frozen_string_literal: true

require "dry-initializer"
require "dry/schema"

module ENVV
  class Builder
    extend Dry::Initializer

    param :schema
    param :env

    class << self
      def call(*params)
        new(*params).call
      end

      def to_proc
        method(:call).to_proc
      end
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
