require_relative '../controllers/user_controller'
require_relative '../views/user_view'
require_relative '../controllers/transactions_controller'

class CLI
  def initialize
    @controller = UserController.new
    @transactions_controller = TransactionsController.new
    @view = UserView.new
  end

  def run
    puts 'Welcome to PERFECT Banking!'

    loop do
      display_menu
      choice = gets.chomp.to_i

      case choice
      when 1
        create_account
      when 2
        edit_account
      when 3
        delete_account
      when 4
        check_balance
      when 5
        deposit_funds
      when 6
        withdraw_money
      when 7
        transfer_funds
      when 8
        puts 'Thank you for using PERFECT Banking!'
        break
      else
        puts 'Invalid option. Please try again.'
      end
    end
  end

  private

  def display_menu
    puts '1. Create Account'
    puts '2. Edit account'
    puts '3. Delete account'
    puts '4. Check Balance'
    puts '5. Deposit Funds'
    puts '6. Withdraw Money'
    puts '7. Transfer Funds'
    puts '8. Exit'
    print 'Enter your option (1-8):  '
  end

  def create_account
    name, job, email, address = nil

     loop do
      print 'Enter your name: '
      name = gets.chomp
      account = Account.new(id: 'TEMP', name: name, job: 'temp', email: 'temp@temp.com', address: 'temp')
      name_error = account.errors.find { |e| e.include?('Name') }
      break unless name_error
      @view.display_error(name_error)
    end

    loop do
      print 'Enter your job: '
      job = gets.chomp
      account = Account.new(id: 'TEMP', name: 'temp', job: job, email: 'temp@example.com', address: 'temp')
      job_error = account.errors.find { |e| e.include?('Job') }
      break unless job_error
      @view.display_error(job_error)
    end

    loop do
      print 'Enter email: '
      email = gets.chomp
      account = Account.new(id: 'TEMP', name: 'temp', job: 'temp', email: email, address: 'temp')
      email_error = account.errors.find { |e| e.include?('Email') }
      break unless email_error
      @view.display_error(email_error)
    end

    loop do
      print 'Enter your address: '
      address = gets.chomp
      account = Account.new(id: 'TEMP', name: 'temp', job: 'temp', email: 'temp@example.com', address: address)
      address_error = account.errors.find { |e| e.include?('Address') }
      break unless address_error
      @view.display_error(address_error)
    end

    result = @controller.create_account(name: name, job: job, email: email, address: address)
    if result[:success]
      @view.display_success('Account created successfully!')
      @view.display_account_details(result[:account])
    else
      @view.display_error(result[:error])
    end
  end

  def edit_account
    print 'Enter account ID to edit: '
    id = gets.chomp
    account = UserRepository.find_account_by_id(id)
    @view.display_error('Account not found.') unless account
  
    

    name = @view.prompt_for_field('name')
    job = @view.prompt_for_field('job')
    email = @view.prompt_for_field('email')
    address = @view.prompt_for_field('address')

    result = @controller.edit_account(id: id, name: name, job: job, email: email, address: address)
    if result[:success]
      @view.display_success('Account updated successfully!')
      @view.display_account_details(result[:account])
    else
      @view.display_error(result[:error])
    end
  end

  def delete_account
    print 'Enter account ID to delete: '
    id = gets.chomp

    account = UserRepository.find_account_by_id(id)
    @view.display_error('Account not found.') unless account
  
   

    result = @controller.delete_account(id)
    if result[:success]
      @view.display_success('Account deleted successfully!')
    else
      @view.display_error(result[:error])
    end
  end

  def check_balance
    print 'Enter account ID to check balance: '
    id = gets.chomp

    account = UserRepository.find_account_by_id(id)
    @view.display_error('Account not found.') unless account
  

    result = @transactions_controller.check_balance(id)
    if result[:success]
      @view.display_success("Balance for account ID #{id}: $#{'%.2f' % result[:account].balance}")
    else
      @view.display_error(result[:error])
    end
  end

  def deposit_funds
    print 'Enter account ID to deposit money: '
    id = gets.chomp

    account = UserRepository.find_account_by_id(id)
    @view.display_error('Account not found.') unless account

    amount = nil
    loop do
      print 'Enter amount to deposit: '
      amount = gets.chomp
      begin
        amount = Float(amount)
        break if amount > 0
        @view.display_error('Amount must be positive. Please try again.')
      rescue ArgumentError
        @view.display_error('Invalid amount format. Please try again.')
      end
    end

    result = @transactions_controller.deposit(id, amount)
    if result[:success]
      @view.display_success(result[:message])
    else
      @view.display_error(result[:error])
    end
  end

  def withdraw_money
    print 'Enter account ID to withdraw money: '
    id = gets.chomp   
    account = UserRepository.find_account_by_id(id)
    @view.display_error('Account not found.') unless account  

    amount = nil
    loop do
      print 'Enter amount to withdraw: '
      amount = gets.chomp
      begin
        amount = Float(amount)
        break if amount > 0
        @view.display_error('Amount must be positive. Please try again.')
      rescue ArgumentError
        @view.display_error('Invalid amount format. Please try again.')
      end
    end

    result = @transactions_controller.withdraw(id, amount)
    if result[:success]
      @view.display_success(result[:message])
    else
      @view.display_error(result[:error])
    end  
  end

  def transfer_funds
    print 'Enter source account ID: '
    from_id = gets.chomp

    from_account = UserRepository.find_account_by_id(from_id)
    @view.display_error('Account not found.') unless from_account

    print 'Enter destination account ID: '
    to_id = gets.chomp  

    to_account = UserRepository.find_account_by_id(to_id)
    @view.display_error('Account not found.') unless to_account  

    amount = nil
    loop do
      print 'Enter amount to transfer: '
      amount = gets.chomp
      begin
        amount = Float(amount)
        break if amount > 0
        @view.display_error('Amount must be positive. Please try again.')
      rescue ArgumentError
        @view.display_error('Invalid amount format. Please try again.')
      end
    end

    result = @transactions_controller.transfer(from_id, to_id, amount)
    if result[:success]
      @view.display_success(result[:message])
    else
      @view.display_error(result[:error])
    end
  end

CLI.new.run
end