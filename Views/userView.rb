class UserView
  def display_success(message)
    puts message
  end

  def display_error(message)
    puts "Error: #{message}"
  end

  def display_account_details(account)
    puts "Account ID: #{account.id}"
    puts "Name: #{account.name}"
    puts "Job: #{account.job}"
    puts "Email: #{account.email}"
    puts "Address: #{account.address}"
    puts "Balance: $#{'%.2f' % account.balance}"
    puts "Transactions: #{account.transactions.join(', ')}"
  end
end
