# frozen_string_literal: true

require_relative "envv/version"
require "singleton"
require "dry/schema"

module ENVV
  class Error < StandardError; end

  class InvalidSchemaError < Error; end

  class InvalidEnvError < Error; end

  class ValidationError < Error; end

  # require "envv/registry"
  class Registry < ::Hash
    include ::Singleton
  end

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

  module_function

  def build!(schema:, env: ENV)
    builder = Builder.new schema: schema, env: env
    @coerced_env_vars = builder.call!
    freeze
    ENVV
  end

  def [](key)
    @coerced_env_vars[key.to_s]
  end

  def fetch(key, *args, **options, &block)
    @coerced_env_vars.fetch(key.to_s, *args, **options, &block)
  end
end
