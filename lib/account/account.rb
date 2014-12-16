class Excoin::Account
  attr_reader :name, :active_wallet_count, :active_wallets,
             :inactive_wallet_count, :inactive_wallets,
             :deposit_count, :withdrawal_count, :orders, :trades

  def initialize
    self.populate_account_summary
    self.orders
    self.trades
  end

  def orders
    @orders ||= Orders.new
  end

  def order(order_id)
    self.orders.all.select{|order| order.id == order_id}[0]
  end

  def trades
    @trades ||= Trades.new
  end

  def update
    self.populate_account_summary
    @orders.update
    @trades.update
  end

  def populate_account_summary
    begin
      account_data = self.get_summary
      @name = account_data['username']

      @active_wallet_count = account_data['active_wallet_count']

      @active_wallets = Hash.new
      account_data['active_wallets'].each do |w|
        @active_wallets.merge!({w['currency'] => Wallet.new(true, w)})
      end

      @inactive_wallet_count = account_data['inactive_wallet_count']

      @inactive_wallets = Hash.new
      account_data['inactive_wallets'].each do |w|
        @inactive_wallets.merge!({w['currency'] => Wallet.new(false, w)})
      end

      @deposit_count = account_data['deposit_count']

      account_data['deposits'].each do |deposit_data|
        self.wallet(deposit_data['currency']).add_deposit(deposit_data)
      end

      @withdrawal_count = account_data['withdrawal_count']

      account_data['withdrawals'].each do |withdrawal_data|
        self.wallet(withdrawal_data['currency']).add_withdrawal(withdrawal_data)
      end
    rescue
      puts "Error in Excoin::Account.populate_account_summary"
      puts account_data
    end
  end

  def wallets
    if @inactive_wallets.size > 0
      return @active_wallets.merge(@inactive_wallets)
    else
      return @active_wallets
    end
  end

  def wallet(currency)
    self.wallets[currency]
  end

  def deposits(currency = nil)
    if currency
      return self.wallet(currency).deposits
    else
      deposits = Hash.new
      @active_wallets.each_pair do |wallet_currency, wallet|
        deposits.merge!(wallet.deposits)
      end
      return deposits
    end
  end

  def withdrawals(currency = nil)
    if currency
      return self.wallet(currency).withdrawals
    else
      withdrawals = Hash.new
      @active_wallets.each_pair do |wallet_currency, wallet|
        withdrawals.merge!(wallet.withdrawals)
      end
      return withdrawals
    end
  end

  def unconfirmed_deposits
    return self.deposits.select{|id, deposit_object| deposit_object.confirmed == false}
  end

  def unconfirmed_withdrawals
    return self.withdrawals.select{|id, withdrawal_object| withdrawal_object.confirmed == false}
  end

  protected

    def get_summary
      Excoin.api.account_summary
    end

end
