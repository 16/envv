# frozen_string_literal: true

require "test_helper"

class TestEnvv::Builder < Minitest::Test
  def setup
    @schema = Dry::Schema.Params do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
    end
    @invalid_env = {
      "MY_INT_VAR" => "2000"
    }
    @valid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "4000"
    }
  end

  def test_call_should_fail_when_env_vars_doesnt_match_schema
    error = assert_raises(ENVV::ValidationError) do
      ENVV::Builder.new(schema: @schema, env: @invalid_env).call!
    end
    assert_equal 2, error.error_messages.size
  end

  def test_build_should_return_registry_when_env_vars_validation_succeed
    assert_kind_of ENVV::Registry, ENVV::Builder.new(schema: @schema, env: @valid_env).call!
  end

  # TODO: conditions in schema, like environment
end
