# frozen_string_literal: true

require "test_helper"

class TestEnvv < Minitest::Test
  def setup
    @schema = Dry::Schema.Params do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
    end
    @invalid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "2000"
    }
    @valid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "4000"
    }
  end

  def test_that_it_has_a_version_number
    refute_nil ::ENVV::VERSION
  end

  def test_build_should_fail_when_env_vars_doesnt_match_schema
    assert_raises(ENVV::ValidationError) { ENVV.build! schema: @schema, env: @invalid_env }
  end

  def test_build_should_return_registry_when_env_vars_validation_succeed
    assert_kind_of ENVV::Registry, ENVV.build!(schema: @schema, env: @valid_env, freeze: false)
  end

  def test_fetch_should_return_registry_value
    ENVV.build!(schema: @schema, env: @valid_env, freeze: false)
    assert_equal "Hello", ENVV.fetch("MY_STRING_VAR")
  end
end
