class Account
  attr_accessor :id, :name, :job, :email, :address, :balance, :transactions

  DAILY_WITHDRAWAL_LIMIT = 5000.0

  def initialize(id:, name:, job:, email:, address:, balance: 0.0, transactions: [])
    @id = id
    @name = name
    @job = job
    @email = email
    @address = address
    @balance = balance
    @transactions = transactions
  end

  def details
    {
      id:,
      name:,
      job:,
      email:,
      address:,
      balance:,
      transactions:
    }
  end

  def valid?
    errors.empty?
  end
  
  def valid_email?(email)
    /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(email)
  end

  def errors 
    errors = []
    errors << 'Name cannot be empty' if @name.strip.empty?
    errors << 'Job cannot be empty' if @job.strip.empty?
    errors << 'Email does not have the right format' unless valid_email?(@email)
    errors << 'Address cannot be empty' if @address.strip.empty?
    errors
  end

  def deposit(amount, from_id: nil)
    @balance += amount
    transaction = from_id ? "Transfer in: $#{'%.2f' % amount} from #{from_id} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}" : "Deposit: $#{'%.2f' % amount} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    @transactions << transaction
    { success: true }
  end

  def withdraw(amount, to_id: nil)
    return { success: false, error: 'Insufficient funds' } if @balance < amount

    today = Time.now.strftime('%Y-%m-%d')
    daily_total = daily_withdrawal_total(today)
    if daily_total + amount > DAILY_WITHDRAWAL_LIMIT
      return { success: false, error: "Daily withdrawal limit of $#{DAILY_WITHDRAWAL_LIMIT} exceeded" }
    end

    @balance -= amount
    transaction = to_id ? "Transfer out: $#{'%.2f' % amount} to #{to_id} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}" : "Withdrawal: $#{'%.2f' % amount} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    @transactions << transaction
    { success: true }
  end

  def daily_withdrawal_total(date)
    @transactions.sum do |transaction|
      if transaction.match(/^(?:Withdrawal): \$([\d.]+).* at #{date}/)
        Regexp.last_match(1).to_f
      else
        0.0
      end
    end
  end

end
