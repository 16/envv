# frozen_string_literal: true

require "singleton"
require "dry/schema"
require_relative "envv/version"
require_relative "envv/errors"
require_relative "envv/registry"
require_relative "envv/builder"

module ENVV
  module_function

  def build!(schema, env = ENV)
    @registry = Builder.call(schema, env)
    freeze
  end

  def registry
    @registry or raise(NotBuilt)
  end

  def fetch(key, *args, &block)
    registry.fetch(key.to_s, *args, &block)
  end
end
