require 'json'
require_relative '../models/account'

class UserRepository
  @file_path = File.join(File.dirname(__FILE__), '..', 'models', 'users.json')
  
  def self.accounts
    @accounts ||= load_accounts
  end

  def self.save_accounts
    data = { accounts: @accounts.map(&:details) }
    json_data = JSON.pretty_generate(data)
    File.write(@file_path, json_data)
    true
  rescue StandardError => e
    puts "Error saving accounts: #{e.message}"
    puts "File path: #{@file_path}"
    puts "Current directory: #{Dir.pwd}"
    false
  end

  def self.create_account(account)
    accounts << account
    save_accounts
    account
  end

  def self.find_account_by_id(id)
    accounts.find { |account| account.id == id }
  end

  def self.update_account(account)
    index = accounts.find_index { |a| a.id == account.id }
    return false unless index

    accounts[index] = account
    save_accounts
    true
  end

  def self.delete_account(id)
    index = accounts.index { |a| a.id == id }
    return false unless index

    accounts.delete_at(index)
    save_accounts
    true
  end

  def self.all_accounts
    accounts
  end

  private

  def self.load_accounts
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
        accounts || []
      rescue JSON::ParserError => e
        puts "Error parsing JSON: #{e.message}, returning empty array"
        []
      end
    else
      puts "File #{@file_path} does not exist, returning empty array"
      []
    end
  end

end
