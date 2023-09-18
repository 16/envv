# frozen_string_literal: true

require "singleton"
require "dry/schema"
require_relative "envv/version"
require_relative "envv/errors"
require_relative "envv/registry"
require_relative "envv/builder"

module ENVV
  module_function

  # Validates ENV vars with schema rules and store coerced values in ENVV registry
  # @param [Proc] A block with Dry::Schema.Params rules
  # @raise [ENVV::InvalidSchemaError] if env vars requirements are not validated
  # @return [ENVV]
  def build!(&rules)
    rules or raise ArgumentError, <<~MESSAGE
      A block of schema rules is required to build ENVV.
          Example:

            ENVV.build! do
              required(:MY_STRING_VAR).filled(:string)
              required(:MY_INT_VAR).filled(:integer, gt?: 3000)
              required(:MY_BOOLEAN_VAR).filled(:bool)
            end

          More info:

          - https://dry-rb.org/gems/dry-schema
          - https://github.com/16/envv

    MESSAGE

    @schema = ::Dry::Schema.Params(&rules)
    @registry = Builder.call(ENV, @schema)
    freeze
  end

  # @raise [ENVV::NotBuilt] error if called before ENVV built (see #build!)
  # @return [Dry::Schema.Params] used to validate environment variables
  def schema
    @schema
  end

  # @raise [ENVV::NotBuilt] error if called before ENVV built (see #build!)
  # @return [ENVV::Registry] Hash-like instance created at build
  def registry
    @registry or raise(NotBuilt)
  end

  # Fetch a coerced environment variable.
  #   This method use the same signature as Hash#fetch.
  # @raise [KeyError] if `key` is not found and neither `default_value` nor a block was given.
  # @overload fetch(key)
  #   @param key [String, Symbol]
  #   @return the value of the given `key` if found.
  # @overload fetch(key, default_value)
  #   @param key [String, Symbol]
  #   @param default_value
  #   @return `default_value` if `key` is not found and no block was given
  # @overload fetch(key, &block)
  #   @yields `key` to the block if `key` is not found and a block was given
  #   @return the block's return value.
  def fetch(key, default_value = nil, &block)
    registry.fetch(key.to_s, default_value, &block)
  end

  public :build!, :schema, :registry, :fetch
end
