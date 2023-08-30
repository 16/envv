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

  module_function

  def build!(schema:, env: ENV, freeze: true)
    unless schema.is_a? ::Dry::Schema::Params
      raise InvalidSchemaError
    end

    unless env.is_a? ::Enumerable
      raise InvalidEnvError
    end

    keys = schema.key_map.map { |key| key.name }
    env_vars = env.select { |name, value| keys.include?(name) }
    result = schema.call(env_vars)
    if result.failure?
      raise ValidationError
    else
      @coerced_env_vars = Registry.instance.replace result.to_h.transform_keys(&:to_s)
      @coerced_env_vars.freeze if freeze
    end
    @coerced_env_vars
  end

  def [](key)
    @coerced_env_vars[key.to_s]
  end

  def fetch(key, *args, **options, &block)
    @coerced_env_vars.fetch(key.to_s, *args, **options, &block)
  end
end
