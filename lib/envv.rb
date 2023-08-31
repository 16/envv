# frozen_string_literal: true

require "singleton"
require "dry/schema"
require_relative "envv/version"
require_relative "envv/errors"
require_relative "envv/registry"
require_relative "envv/builder"

module ENVV
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
