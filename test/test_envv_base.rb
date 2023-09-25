# frozen_string_literal: true

require "test_helper"

class TestEnvvBase < Minitest::Test
  def setup
    ENV["MY_STRING_VAR"] = "Hello"
    ENV["MY_INT_VAR"] = "4000"
    ENV["MY_BOOLEAN_VAR"] = "0"

    @not_built_envv = Class.new do
      include(ENVV::Base)
    end.new

    @envv = Class.new do
      include(ENVV::Base)
    end.new

    @built_envv = @envv.build! do
      required(:MY_STRING_VAR).filled(:string)
      required(:MY_INT_VAR).filled(:integer, gt?: 3000)
      required(:MY_BOOLEAN_VAR).filled(:bool)
    end
  end

  def test_must_respond_to_envv_base_methods
    assert_respond_to @not_built_envv, :build!
    assert_respond_to @not_built_envv, :schema
    assert_respond_to @not_built_envv, :registry
    assert_respond_to @not_built_envv, :fetch
  end

  def test_must_build_only_with_a_block_of_rules
    assert @not_built_envv.method(:build!).arity.zero?
    assert_raises(ArgumentError) do
      @not_built_envv.build!
    end
  end

  def test_registry_and_fetch_methods_should_raise_exception_if_not_built
    assert_raises(ENVV::NotBuilt) { @not_built_envv.registry }
    assert_raises(ENVV::NotBuilt) { @not_built_envv.fetch("MY_STRING_VAR") }
  end

  def test_when_build_should_return_itself_and_be_frozen
    refute @not_built_envv.frozen?
    assert_equal @built_envv, @envv
    assert @envv.frozen?
  end

  def test_should_return_registry_if_built
    assert_instance_of ENVV::Registry, @built_envv.registry
  end

  def test_should_return_schema
    assert_instance_of ::Dry::Schema::Params, @built_envv.schema
  end

  def test_registry_should_be_frozen
    assert @built_envv.registry.frozen?
  end

  def test_fetch_should_return_registry_coerced_value
    assert_equal "Hello", @built_envv.fetch("MY_STRING_VAR")
    assert_equal 4000, @built_envv.fetch("MY_INT_VAR")
    refute @built_envv.fetch("MY_BOOLEAN_VAR")
  end

  def test_fetch_can_also_use_symbols_as_keys
    assert_equal "Hello", @built_envv.fetch(:MY_STRING_VAR)
  end
end
