class Excoin::Account::Wallet
  attr_reader :status, :currency, :deposit_address, :confirmed_balance,
              :available_balance, :order_balance,
              :pending_deposit_balance, :pending_withdrawal_balance,
              :deposits, :withdrawals

  def initialize(active, wallet_data)
    begin
      if active
        @status = "active"
        @currency = wallet_data['currency']
        @deposits = Hash.new
        @withdrawals = Hash.new
        @deposit_address = wallet_data['address']
        @confirmed_balance = BigDecimal.new(wallet_data['confirmed_balance'])
        @available_balance = BigDecimal.new(wallet_data['available_balance'])
        @order_balance = BigDecimal.new(wallet_data['order_balance'])
        @pending_deposit_balance = BigDecimal.new(wallet_data['pending_deposit_balance'])
        @pending_withdrawal_balance = BigDecimal.new(wallet_data['pending_withdrawal_balance'])
      else
        @status = "inactive"
        @currency = wallet_data['currency']
        @deposit_address = wallet_data['address']
      end
    rescue
      puts "Error in Excoin::Account::Wallet.initialize"
      puts wallet_data
    end
  end

  def update(wallet_data)
    begin
      if wallet_data['address']
        @deposit_address = wallet_data['address']
      end
      @confirmed_balance = BigDecimal.new(wallet_data['confirmed_balance'])
      @available_balance = BigDecimal.new(wallet_data['available_balance'])
      @order_balance = BigDecimal.new(wallet_data['order_balance'])
      @pending_deposit_balance = BigDecimal.new(wallet_data['pending_deposit_balance'])
      @pending_withdrawal_balance = BigDecimal.new(wallet_data['pending_withdrawal_balance'])
    rescue
      puts "Error in Excoin::Account::Wallet.update"
      puts wallet_data
    end
  end

  def unconfirmed_deposits
    return @deposits.select{|id, deposit_object| deposit_object.confirmed == false}
  end

  def unconfirmed_withdrawals
    return @withdrawals.select{|id, withdrawal_object| withdrawal_object.confirmed == false}
  end

  def add_deposit(deposit_data)
    @deposits.merge!({deposit_data['txid'] => Deposit.new(deposit_data)})
  end

  def add_withdrawal(withdrawal_data)
    @withdrawals.merge!({withdrawal_data['id'] => Withdrawal.new(withdrawal_data)})
  end

  def withdraw(address, amount)
    if BigDecimal.new(amount) <= self.available_balance
      withdrawal_data = Excoin.api.account_withdraw(self.currency, address, amount)
      Excoin.account.add_withdrawal(withdrawal_data)
    else
      puts "Insufficient funds for withdrawal"
    end
  end

end
