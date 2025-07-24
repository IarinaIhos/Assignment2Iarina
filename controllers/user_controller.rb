require_relative '../models/account'
require_relative '../repositories/user_repository'

class UserController

  def create_account(params)
    name = params[:name]
    job = params[:job]
    email = params[:email]
    address = params[:address]

    id = generate_account_id
    account = Account.new(id: id, name: name, job: job, email: email, address: address)

    unless account.valid?
      return { success: false, error: account.errors.first }
    end

    UserRepository.create_account(account)
    { success: true, account: account }
  end

  def edit_account(params)
    id = params[:id]
    name = params[:name]
    job = params[:job]
    email = params[:email]
    address = params[:address]

    account = UserRepository.find_account_by_id(id)
    return { success: false, error: 'Account not found' } unless account

    name = name.nil? || name.strip.empty? ? account.name : name
    job = job.nil? || job.strip.empty? ? account.job : job
    email = email.nil? || email.strip.empty? ? account.email : email
    address = address.nil? || address.strip.empty? ? account.address : address

    temp_account = Account.new(id: id, name: name, job: job, email: email, address: address)
    unless temp_account.valid?
      return { success: false, error: temp_account.errors.first }
    end

    account.name = name if name
    account.job = job if job
    account.email = email if email
    account.address = address if address

    { success: UserRepository.update_account(account), account: account }
  end

  def delete_account(id)
    success = UserRepository.delete_account(id)
    if success
      { success: true, message: 'Account deleted successfully' }
    else
      { success: false, error: 'Account not found' }
    end
  end

  def generate_account_id
    loop do
      id = "ACC#{rand(100..999)}"
      return id unless UserRepository.find_account_by_id(id)
    end
  end

  def check_balance(id)
    account = UserRepository.find_account_by_id(id)
    if account
      { success: true, account: account }
    else
      { success: false, error: 'Account not found' }
    end
  end

end