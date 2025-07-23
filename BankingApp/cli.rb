require_relative '../Controllers/userController'
require_relative '../Views/userView'

class CLI
  def initialize
    @controller = UserController.new
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
    puts '5. Transfer Money'
    puts '6. Exit'
    print 'Enter your option (1-5):  '
  end

  def create_account
    name = nil
    loop do
      print 'Enter your name: '
      name = gets.chomp
      break unless name.strip.empty?

      @view.display_error('Name cannot be empty. Please try again.')
    end

    job = nil
    loop do
      print 'Enter your job: '
      job = gets.chomp
      break unless job.strip.empty?

      @view.display_error('Job cannot be empty. Please try again.')
    end

    email = nil
    loop do
      print 'Enter email: '
      email = gets.chomp
      break if @controller.valid_email?(email)

      @view.display_error('Invalid email format. Please try again.')
    end

    address = nil
    loop do
      print 'Enter your address: '
      address = gets.chomp
      break unless address.strip.empty?

      @view.display_error('Address cannot be empty. Please try again.')
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

    print 'Enter new name (leave blank to keep current): '
    name = gets.chomp

    print 'Enter new job (leave blank to keep current): '
    job = gets.chomp

    print 'Enter new email (leave blank to keep current): '
    email = gets.chomp

    print 'Enter new address (leave blank to keep current): '
    address = gets.chomp
    result = @controller.edit_account(id: id, name: name.empty? ? nil : name, job: job.empty? ? nil : job,
                                      email: email.empty? ? nil : email, address: address.empty? ? nil : address)
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

    account = @controller.instance_variable_get(:@repository).find_account_by_id(id)

    if account
      @view.display_success("Balance for account ID #{id}: $#{'%.2f' % account.balance}")
    else
      @view.display_error('Account not found.')
    end
  end
end

CLI.new.run
