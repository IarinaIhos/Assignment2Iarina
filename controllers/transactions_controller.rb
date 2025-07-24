require_relative '../models/account'
require_relative '../repositories/user_repository'

class TransactionsController
  def check_balance(id)
    account = UserRepository.find_account_by_id(id)
    if account
      { success: true, account: account }
    else
      { success: false, error: 'Account not found' }
    end
  end

  def deposit(id, amount)
    begin
      amount = Float(amount)
      return { success: false, error: 'Amount must be positive' } unless amount > 0

      account = UserRepository.find_account_by_id(id)
      return { success: false, error: 'Account not found' } unless account

      deposit_result = account.deposit(amount)
      return deposit_result unless deposit_result[:success]

      UserRepository.update_account(account)
      { success: true, account: account, message: "Deposited $#{'%.2f' % amount} to account #{id}" }
    rescue ArgumentError
      { success: false, error: 'Invalid amount format' }
    end
  end

  def withdraw(id, amount)
    begin
      amount = Float(amount)
      return { success: false, error: 'Amount must be positive' } unless amount > 0

      account = UserRepository.find_account_by_id(id)
      return { success: false, error: 'Account not found' } unless account

      withdraw_result = account.withdraw(amount)
      return withdraw_result unless withdraw_result[:success]

      UserRepository.update_account(account)
      { success: true, account: account, message: "Withdrew $#{'%.2f' % amount} from account #{id}" }
    rescue ArgumentError
      { success: false, error: 'Invalid amount format' }
    end
  end

  def transfer(from_id, to_id, amount)
    begin
      amount = Float(amount)
      return { success: false, error: 'Amount must be positive' } unless amount > 0

      from_account = UserRepository.find_account_by_id(from_id)
      return { success: false, error: 'Source account not found' } unless from_account

      to_account = UserRepository.find_account_by_id(to_id)
      return { success: false, error: 'Destination account not found' } unless to_account

      withdraw_result = from_account.withdraw(amount, to_id: to_id)
      return withdraw_result unless withdraw_result[:success]

      deposit_result = to_account.deposit(amount, from_id: from_id)
      return deposit_result unless deposit_result[:success]

      UserRepository.update_account(from_account)
      UserRepository.update_account(to_account)
      { success: true, from_account: from_account, to_account: to_account, message: "Transferred $#{'%.2f' % amount} from #{from_id} to #{to_id}" }
    rescue ArgumentError
      { success: false, error: 'Invalid amount format' }
    end
  end
end