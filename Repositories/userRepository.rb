require 'json'
require_relative '../BankingApp/account'

class UserRepository
  def initialize(file_path = 'users.json')
    @file_path = file_path
    @users = load_users
    @accounts = load_accounts || []
  end

  def create_account(account)
    @accounts << account
    save_accounts
    account
  end

  def find_account_by_id(id)
    @accounts.find { |account| account.id == id }
  end

  def update_account(account)
    index = @accounts.find_index { |a| a.id == account.id }
    return false unless index

    @accounts[index] = account
    save_accounts
    true
  end

  def delete_account(id)
    index = @accounts.index { |a| a.id == id }
    return false unless index

    @accounts.delete_at(index)
    save_accounts
    true
  end

  def all_accounts
    @accounts
  end

  private

  def load_users
    if File.exist?(@file_path)
      data = JSON.parse(File.read(@file_path), symbolize_names: true)
      data[:accounts]&.map do |account_data|
        Account.new(
          id: account_data[:id],
          name: account_data[:name],
          job: account_data[:job],
          email: account_data[:email],
          address: account_data[:address],
          balance: account_data[:balance],
          transactions: account_data[:transactions] || []
        )
      end || []
    else
      []
    end
  rescue JSON::ParserError
    []
  end

  def load_accounts
    if File.exist?(@file_path)
      begin
        data = JSON.parse(File.read(@file_path), symbolize_names: true)
        accounts = data[:accounts]&.map do |account_data|
          Account.new(
            id: account_data[:id],
            name: account_data[:name],
            job: account_data[:job],
            email: account_data[:email],
            address: account_data[:address],
            balance: account_data[:balance] || 0.0,
            transactions: account_data[:transactions] || []
          )
        end
        puts "Loaded accounts with IDs: #{accounts.map(&:id).join(', ') if accounts}"
        accounts
      rescue JSON::ParserError => e
        puts "Error parsing JSON: #{e.message}, returning empty array"
        []
      end
    else
      puts "File #{@file_path} does not exist, returning empty array"
      []
    end
  end

  def save_accounts
    File.write(@file_path, JSON.pretty_generate(accounts: @accounts.map(&:to_h)))
  rescue StandardError => e
    puts "Error saving accounts: #{e.message}"
    false
  end
end
