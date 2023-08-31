# frozen_string_literal: true

require "test_helper"

class TestEnvv::ValidationError < Minitest::Test
  def setup
    @messages = ["Message 1", "Message 2"]
    @error = ENVV::ValidationError.new(@messages)
  end

  def test_error_messages_should_return_messages_provided_at_initialization
    assert_equal @messages, @error.error_messages
  end
end
