class Account
  attr_accessor :id, :name, :job, :email, :address, :balance, :transactions

  def initialize(id:, name:, job:, email:, address:, balance: 0.0, transactions: [])
    @id = id
    @name = name
    @job = job
    @email = email
    @address = address
    @balance = balance
    @transactions = transactions
  end

  def to_h
    {
      id: @id,
      name: @name,
      job: @job,
      email: @email,
      address: @address,
      balance: @balance,
      transactions: @transactions
    }
  end
end
