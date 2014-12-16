class Excoin::Account::Wallet::Withdrawal
  attr_reader :id, :timestamp, :currency, :address,
              :amount, :confirmed

  def initialize(withdrawal_data)
    begin
      @id = withdrawal_data['id']
      @timestamp = Time.parse(withdrawal_data['timestamp'])
      @currency = withdrawal_data['currency']
      @address = withdrawal_data['address']
      @amount = BigDecimal.new(withdrawal_data['amount'])
      @confirmed = withdrawal_data['confirmed']
    rescue
      puts "Error in Excoin::Account::Withdrawal.initialize"
      puts withdrawal_data
    end
  end

## to be implemented in API in the future
#
#  def cancel_withdrawal(withdrawal_id)
#  end
#
#  def initiate_withdrawal
#  end

end
