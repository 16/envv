# frozen_string_literal: true

require "singleton"
require "dry/schema"
require_relative "envv/version"
require_relative "envv/errors"
require_relative "envv/registry"
require_relative "envv/builder"

module ENVV
  module_function

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

  def schema
    @schema
  end

  def registry
    @registry or raise(NotBuilt)
  end

  def fetch(key, *args, &block)
    registry.fetch(key.to_s, *args, &block)
  end

  public :build!, :registry, :fetch
end
