# frozen_string_literal: true

class Bank
  def initialize(player_account, diller_account)
    @player_account = player_account
    @diller_account = diller_account
    @bank_account = 0
  end

  def bet
    players_account.each do |account|
      account -= 10
      @bank_account += 10
    end
  end

  def players_account
    [player_account, diller_account]
  end

  def player_win
    give_gain(players_account)
  end

  def diller_win
    give_gain(diller_account)
  end

  def give_gain(account)
    account += 20
    @bank_account = 0
  end

  def draw
    player_account += @bank_account / 2
    diller_account += @bank_account / 2
    @bank_account = 0
  end

  private

  attr_accessor :bank_account, :player_account, :diller_account
end
