require 'spec_helper'

describe Excoin::Account do
  subject {Excoin.account.wallet($currency)}

  it "has complete Deposit objects" do
    unless subject.deposits.empty?
      subject.deposits.each_value do |deposit|
        expect(deposit).to be_an(Excoin::Account::Wallet::Deposit)
        expect(deposit.id).to be_a(String)
        expect(deposit.timestamp).to be_a(Time)
        expect(deposit.currency).to be_a(String)
        expect(deposit.address).to be_a(String)
        expect(deposit.amount).to be_a(BigDecimal)
        expect(deposit.confirmed).to be_a(TrueClass).or be_a(FalseClass)
      end
    end

  end

  it "has complete Withdrawal objects" do
    unless subject.withdrawals.empty?
      subject.withdrawals.each_value do |withdrawal|
        expect(withdrawal).to be_an(Excoin::Account::Wallet::Withdrawal)
        expect(withdrawal.id).to be_a(String)
        expect(withdrawal.timestamp).to be_a(Time)
        expect(withdrawal.currency).to be_a(String)
        expect(withdrawal.address).to be_a(String)
        expect(withdrawal.amount).to be_a(BigDecimal)
        expect(withdrawal.confirmed).to be_a(TrueClass).or be_a(FalseClass)
      end
    end
  end

  it ".deposits returns hash of all deposits" do
    expect(subject.deposits).to be_a(Hash)
    unless subject.deposits.empty?
      subject.deposits.each_pair do |id, deposit_object|
        expect(deposit_object).to be_a(Excoin::Account::Wallet::Deposit)
      end
    end
  end

  it ".withdrawals returns hash of all withdrawals" do
    expect(subject.withdrawals).to be_a(Hash)
    unless subject.withdrawals.empty?
      subject.withdrawals.each_pair do |id, withdrawal_object|
        expect(withdrawal_object).to be_a(Excoin::Account::Wallet::Withdrawal)
      end
    end
  end

  it ".unconfirmed_deposits returns hash" do
    expect(subject.unconfirmed_deposits).to be_a(Hash)
    subject.unconfirmed_deposits.each_pair do |id, deposit_object|
      expect(deposit_object.confirmed).to be false
    end
  end

  it ".unconfirmed_withdrawals returns hash" do
    expect(subject.unconfirmed_withdrawals).to be_a(Hash)
    subject.unconfirmed_withdrawals.each_pair do |id, withdrawal_object|
      expect(withdrawal_object.confirmed).to be false
    end
  end

end
