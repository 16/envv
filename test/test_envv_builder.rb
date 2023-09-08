# frozen_string_literal: true

require "test_helper"

class TestEnvv::Builder < Minitest::Test
  def setup
    @schema = Dry::Schema.Params do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
      required(:MY_BOOLEAN_VAR).filled(:bool)
    end

    @invalid_env = {
      "MY_INT_VAR" => "2000",
      "MY_BOOLEAN_VAR" => "true"
    }
    @valid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "4000",
      "MY_BOOLEAN_VAR" => "true"
    }
  end

  def test_must_be_instanciated_with_a_schema_instance
    builder = ENVV::Builder.new(@valid_env, @schema)
    assert_instance_of ENVV::Builder, builder
  end

  def test_call_should_fail_when_there_is_no_schema_definition
    assert_raises(ENVV::InvalidSchemaError) do
      ENVV::Builder.call(@valid_env)
    end
  end

  def test_call_should_fail_when_env_vars_doesnt_match_schema
    error = assert_raises(ENVV::ValidationError) do
      ENVV::Builder.call(@invalid_env, @schema)
    end
    assert_equal 2, error.error_messages.size
  end

  def test_build_should_return_a_frozen_registry_when_env_vars_validation_succeed
    registry = ENVV::Builder.call(@valid_env, @schema)
    assert_instance_of ENVV::Registry, registry
    assert registry.frozen?
  end

  def test_returned_registry_must_have_coerced_values
    registry = ENVV::Builder.call(@valid_env, @schema)
    assert_instance_of Integer, registry.fetch("MY_INT_VAR")
    assert_instance_of TrueClass, registry.fetch("MY_BOOLEAN_VAR")
  end
end
