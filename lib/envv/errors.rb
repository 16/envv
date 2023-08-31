# frozen_string_literal: true

module ENVV
  class Error < ::StandardError; end

  class InvalidSchemaError < Error
    def initialize
      super("A ::Dry::Schema::Params is expected. See https://github.com/16/envv#schema.")
    end
  end

  class InvalidEnvError < Error
    def initialize
      super("ENV or an an enumerable is expected.")
    end
  end

  class ValidationError < Error
    ERROR_MESSAGE_TITLE = "Environment variables validation failed:"

    attr_reader :error_messages

    def initialize(error_messages)
      @error_messages = error_messages
      super(full_error_message.join("\n"))
    end

    private

    def full_error_message
      messages = [ERROR_MESSAGE_TITLE]
      messages.concat(@error_messages.map { |v| "\t* #{v}" })
      messages << " "
    end
  end
end
