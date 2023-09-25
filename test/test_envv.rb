# frozen_string_literal: true

require "test_helper"

class TestEnvv < Minitest::Test
  def setup
    ENV["MY_STRING_VAR"] = "Hello"
    ENV["MY_INT_VAR"] = "4000"
    ENV["MY_BOOLEAN_VAR"] = "0"

    @envv = if ENVV.frozen?
      ENVV
    else
      ENVV.build! do
        required(:MY_STRING_VAR).filled(:string)
        required(:MY_INT_VAR).filled(:integer, gt?: 3000)
        required(:MY_BOOLEAN_VAR).filled(:bool)
      end
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::ENVV::VERSION
  end

  def test_must_respond_to_envv_base_methods
    assert_respond_to ENVV, :build!
    assert_respond_to ENVV, :schema
    assert_respond_to ENVV, :registry
    assert_respond_to ENVV, :fetch
  end

  def test_when_build_should_return_itself_and_be_frozen
    assert_equal ENVV, @envv
    assert ENVV.frozen?
  end

  def test_should_return_registry_if_built
    assert_instance_of ENVV::Registry, @envv.registry
  end

  def test_should_return_schema
    assert_instance_of ::Dry::Schema::Params, @envv.schema
  end

  def test_fetch_should_return_registry_coerced_value
    assert_equal "Hello", @envv.fetch("MY_STRING_VAR")
    assert_equal 4000, @envv.fetch("MY_INT_VAR")
    refute @envv.fetch("MY_BOOLEAN_VAR")
  end
end
