require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../controllers/user_controller'
require_relative '../models/account'

class UserControllerTest < Minitest::Test
  def setup
    @controller = UserController.new
  end

  def test_create_account_with_valid_parameters
    params = {
      name: 'Iarina Ihos',
      job: 'Developer',
      email: 'iarina@email.com',
      address: 'Emile Zola'
    }

    account = Account.new(
      id: 'ACC123',
      name: params[:name],
      job: params[:job],
      email: params[:email],
      address: params[:address]
    )

    UserController.any_instance.stubs(:generate_account_id).returns('ACC123')
    UserRepository.expects(:create_account).returns(true)

    result = @controller.create_account(params)

    assert_equal true, result[:success]
    assert_instance_of Account, result[:account]
    assert_equal 'Iarina Ihos', result[:account].name
    assert_equal 'Developer', result[:account].job
    assert_equal 'iarina@email.com', result[:account].email
    assert_equal 'Emile Zola', result[:account].address
  end

  def test_create_account_with_invalid_email
    params = {
      name: 'Iarina Ihos',
      job: 'Developer',
      email: 'invalid-email',
      address: 'Emile Zola'
    }

    result = @controller.create_account(params)

    assert_equal false, result[:success]
    assert_match(/Email does not have the right format/, result[:error])
  end

  def test_create_account_with_missing_required_fields
    params = {
      name: '',
      job: 'Developer',
      email: 'iarina@email.com',
      address: 'Emile Zola'
    }

    result = @controller.create_account(params)

    assert_equal false, result[:success]
    assert_match(/name/i, result[:error])
  end

  def test_generate_account_id_format
    UserRepository.stubs(:find_account_by_id).returns(nil)

    id = @controller.generate_account_id

    assert_match(/^ACC\d{3}$/, id)
  end

  def test_generate_account_id_uniqueness
    UserRepository.stubs(:find_account_by_id)
                  .returns(true)
                  .then.returns(true)
                  .then.returns(false)

    id = @controller.generate_account_id

    assert_match(/^ACC\d{3}$/, id)
  end
end
