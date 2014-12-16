require 'spec_helper'

describe Excoin::Account, vcr: { cassette_name: "account_summary", match_requests_on: [:method, :uri_without_timestamp], record: :new_episodes } do
  subject {Excoin.account}

  it "is a complete Excoin::Account object" do
    expect(subject).to be_an(Excoin::Account)
    expect(subject.name).to be_a(String)
    expect(subject.active_wallet_count).to be_an(Integer)
    expect(subject.active_wallets).to be_a(Hash)
    expect(subject.inactive_wallet_count).to be_an(Integer)
    expect(subject.inactive_wallets).to be_a(Hash)
    expect(subject.deposit_count).to be_an(Integer)
    expect(subject.withdrawal_count).to be_an(Integer)
    expect(subject.orders).to be_an(Excoin::Account::Orders)
    expect(subject.trades).to be_an(Excoin::Account::Trades)
  end

  it "active/inactive wallets in right wallets hash" do
    subject.active_wallets.each_pair do |currency, wallet|
      expect(wallet.status).to eq("active")
    end
    subject.inactive_wallets.each_pair do |currency, wallet|
      expect(wallet.status).to eq("inactive")
    end
  end

  context "transactions without currency param" do
    # Passes if API doesn't connect because it makes the empty hash anyway
    it ".deposits returns hash of all deposits" do
      expect(subject.deposits).to be_a(Hash)
      unless subject.deposits.empty?
        subject.deposits.each_pair do |id, deposit_object|
          expect(deposit_object).to be_a(Excoin::Account::Wallet::Deposit)
        end
      end
    end

    # Passes if API doesn't connect because it makes the empty hash anyway
    it ".withdrawals returns hash of all withdrawals" do
      expect(subject.withdrawals).to be_a(Hash)
      unless subject.withdrawals.empty?
        subject.withdrawals.each_pair do |id, withdrawal_object|
          expect(withdrawal_object).to be_a(Excoin::Account::Wallet::Withdrawal)
        end
      end
    end
  end

  context "transactions with currency param" do
    it "returns hash of deposits matching currency" do
      deposits_by_currency = subject.deposits($currency)
      expect(deposits_by_currency).to be_a(Hash)
      unless deposits_by_currency.empty?
        deposits_by_currency.each_pair do |id, deposit_object|
          expect(deposit_object).to be_a(Excoin::Account::Wallet::Deposit)
          expect(deposit_object.currency).to eq($currency)
        end
      end
    end

    it "returns hash of withdrawals matching currency" do
      withdrawals_by_currency = subject.withdrawals($currency)
      expect(withdrawals_by_currency).to be_a(Hash)
      unless withdrawals_by_currency.empty?
        withdrawals_by_currency.each_pair do |id, withdrawal_object|
          expect(withdrawal_object).to be_a(Excoin::Account::Wallet::Withdrawal)
          expect(withdrawal_object.currency).to eq($currency)
        end
      end
    end
  end

  it ".unconfirmed_deposits returns hash" do
    subject.unconfirmed_deposits.each_pair do |id, deposit_object|
      expect(deposit_object).to be_a(Excoin::Account::Wallet::Deposit)
      expect(deposit_object.confirmed).to be false
    end
  end

  it ".unconfirmed_withdrawals returns hash" do
    subject.unconfirmed_withdrawals.each_pair do |id, withdrawal_object|
      expect(withdrawal_object).to be_a(Excoin::Account::Wallet::Withdrawal)
      expect(withdrawal_object.confirmed).to be false
    end
  end

  it "has complete Wallet objects" do
    unless subject.wallets.empty?
      subject.wallets.each_value do |wallet|
        expect(wallet).to be_an(Excoin::Account::Wallet)
        expect(wallet.status).to be_a(String)
        expect(wallet.currency).to be_a(String)
        expect(wallet.deposit_address).to be_a(String)
        if wallet.status == "active"
          expect(wallet.confirmed_balance).to be_a(BigDecimal)
          expect(wallet.available_balance).to be_a(BigDecimal)
          expect(wallet.order_balance).to be_a(BigDecimal)
          expect(wallet.pending_deposit_balance).to be_a(BigDecimal)
          expect(wallet.pending_withdrawal_balance).to be_a(BigDecimal)
        end
      end
    end
  end

  it ".wallets returns hash of all wallets" do
    expect(subject.wallets.size).to eq(subject.active_wallet_count + subject.inactive_wallet_count)
  end

  it ".wallet(currency) returns Wallet object matching currency" do
    expect(subject.wallet($currency)).to be_a(Excoin::Account::Wallet)
    expect(subject.wallet($currency).currency).to eq($currency)
  end

  context "Excoin::Account::Order object actions" do
    it ".order(id) returns an Order object matching id", vcr: { cassette_name: "account_view_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: { order_id: $order_id } } do
      order = subject.order($order_id)
      expect(order).to be_an(Excoin::Account::Order)
      expect(order.id).to eq($order_id)
    end

    it "Order.refresh updates existing order with new data", vcr: { cassette_name: "account_view_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: { order_id: $order_id } } do
      original_order_currency_amount = subject.order($order_id).currency_amount
      subject.order($order_id).refresh
      expect(subject.order($order_id).currency_amount).to_not eq(original_order_currency_amount)
    end

    it "Order.cancel cancels and updates selected order", vcr: { cassette_name: "account_cancel_order_erb", match_requests_on: [:method, :uri_without_timestamp], erb: { order_id: $order_id } } do
      pp subject.order($order_id)
      subject.order($order_id).cancel
      pp subject.order($order_id)
      expect(subject.order($order_id).status).to eq("CLOSED")
    end
  end

end
