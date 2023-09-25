# frozen_string_literal: true

require "dry/schema"
require_relative "envv/version"
require_relative "envv/errors"
require_relative "envv/registry"
require_relative "envv/builder"
require_relative "envv/base"

module ENVV
  extend Base
end
