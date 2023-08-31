# frozen_string_literal: true

module ENVV
  class Error < StandardError; end

  class InvalidSchemaError < Error; end

  class InvalidEnvError < Error; end

  class ValidationError < Error; end
end
