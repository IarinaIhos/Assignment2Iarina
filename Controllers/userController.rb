require_relative '../BankingApp/account'
require_relative '../Repositories/userRepository'

class UserController
  def initialize(repository = UserRepository.new)
    @repository = repository
  end

  def create_account(params)
    name = params[:name]
    job = params[:job]
    email = params[:email]
    address = params[:address]

    return { success: false, error: 'Name cannot be empty' } if name.strip.empty?
    return { success: false, error: 'Job title cannot be empty' } if job.strip.empty?
    return { success: false, error: 'Email is invalid' } unless valid_email?(email)
    return { success: false, error: 'Address cannot be empty' } if address.strip.empty?

    id = generate_account_id
    account = Account.new(id: id, name: name, job: job, email: email, address: address)
    @repository.create_account(account)
    { success: true, account: account }
  end

  def edit_account(params)
    id = params[:id]
    name = params[:name]
    job = params[:job]
    email = params[:email]
    address = params[:address]

    account = @repository.find_account_by_id(id)
    return { success: false, error: 'Account not found' } unless account

    name = name.nil? || name.strip.empty? ? account.name : name
    job = job.nil? || job.strip.empty? ? account.job : job
    email = email.nil? || email.strip.empty? ? account.email : email
    address = address.nil? || address.strip.empty? ? account.address : address

    return { success: false, error: 'Email is invalid' } unless email.nil? || valid_email?(email)

    account.name = name if name
    account.job = job if job
    account.email = email if email
    account.address = address if address

    { success: @repository.update_account(account), account: account }
  end

  def delete_account(id)
    success = @repository.delete_account(id)
    if success
      { success: true, message: 'Account deleted successfully' }
    else
      { success: false, error: 'Account not found' }
    end
  end

  def valid_email?(email)
    /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(email)
  end

  def generate_account_id
    loop do
      id = "ACC#{rand(100..999)}"
      return id unless @repository.find_account_by_id(id)
    end
  end
end
