class Excoin::Account::Wallet::Deposit
  attr_reader :timestamp, :currency, :id, :address,
              :amount, :confirmations, :confirmed

  def initialize(deposit_data)
    begin
      @timestamp = Time.parse(deposit_data['timestamp'])
      @currency = deposit_data['currency']
      @id = deposit_data['txid']
      @address = deposit_data['address']
      @amount = BigDecimal.new(deposit_data['amount'])
      @confirmations = deposit_data['confirmations']
      @confirmed = deposit_data['confirmed']
    rescue
      puts "Error in Excoin::Account::Deposit.initialize"
      puts deposit_data
    end
  end

end
