# frozen_string_literal: true

require "test_helper"

class TestEnvv < Minitest::Test
  def setup
    @schema = Dry::Schema.Params do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
      required(:MY_BOOLEAN_VAR).filled(:bool)
    end
    @valid_env = {
      "MY_STRING_VAR" => "Hello",
      "MY_INT_VAR" => "4000",
      "MY_BOOLEAN_VAR" => "0"
    }
    @valid_envv = ENVV.frozen? ? ENVV : ENVV.build!(@schema, @valid_env)
  end

  def test_that_it_has_a_version_number
    refute_nil ::ENVV::VERSION
  end

  def test_should_return_itself_when_build_succeed
    assert_equal ENVV, @valid_envv
  end

  def test_should_be_frozen_after_build_succeed
    assert_raises(FrozenError) { ENVV.build!(@schema, @valid_env) }
  end

  def test_should_return_registry
    assert_kind_of ENVV::Registry, @valid_envv.registry
  end

  def test_registry_should_be_frozen
    assert @valid_envv.registry.frozen?
  end

  def test_fetch_should_return_registry_coerced_value
    assert_equal "Hello", @valid_envv.fetch("MY_STRING_VAR")
    assert_equal 4000, @valid_envv.fetch("MY_INT_VAR")
    refute @valid_envv.fetch("MY_BOOLEAN_VAR")
  end

  def test_fetch_can_also_use_symbols_as_keys
    assert_equal "Hello", @valid_envv.fetch(:MY_STRING_VAR)
  end
end
