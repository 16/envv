# frozen_string_literal: true

require "test_helper"

class TestEnvv < Minitest::Test
  def setup
    @schema = Dry::Schema.Params do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
    end
    @valid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "4000"
    }
    @valid_envv = ENVV.frozen? ? ENVV : ENVV.build!(schema: @schema, env: @valid_env)
  end

  def test_that_it_has_a_version_number
    refute_nil ::ENVV::VERSION
  end

  def test_should_return_itself_when_build_succeed
    assert_equal ENVV, @valid_envv
  end

  def test_should_be_frozen_after_build_succeed
    assert_raises(FrozenError) { ENVV.build!(schema: @schema, env: @valid_env) }
  end

  def test_fetch_should_return_registry_value
    assert_equal "Hello", @valid_envv.fetch("MY_STRING_VAR")
  end
end
