require_relative '../test_helper'
require 'tumugi/parameter/parameter_proxy'

class Tumugi::Parameter::ParameterProxyTest < Test::Unit::TestCase
  setup do
    @proxy = Tumugi::Parameter::ParameterProxy.new('name')
  end

  test '#initialize' do
    assert_equal('name', @proxy.name)
    assert_equal({}, @proxy.params)
  end

  sub_test_case '#param' do
    test 'without opts' do
      @proxy.param(:param1)

      param = @proxy.params[:param1]
      assert_equal(1, @proxy.params.count)
      assert_equal(false, param.auto_bind?)
      assert_equal(false, param.required?)
      assert_equal(:string, param.type)
      assert_equal(nil, param.default_value)
    end

    test 'with opts' do
      opts = {
        auto_bind: true,
        required: false,
        type: :integer,
        default: 1,
      }
      @proxy.param(:param1, opts)

      param = @proxy.params[:param1]
      assert_equal(1, @proxy.params.count)
      assert_equal(true, param.auto_bind?)
      assert_equal(false, param.required?)
      assert_equal(:integer, param.type)
      assert_equal(1, param.default_value)
    end

    test 'raise ParameterError when both required and default is set' do
      assert_raise(Tumugi::ParameterError) do
        @proxy.param(:param1, required: true, default: 'test')
      end
    end
  end

  sub_test_case '#set' do
    test 'should add param_defaults' do
      @proxy.set(:param1, 'value1')
      assert_true(@proxy.param_defaults.has_key?(:param1))
      assert_equal('value1', @proxy.param_defaults[:param1])
    end
  end
end
