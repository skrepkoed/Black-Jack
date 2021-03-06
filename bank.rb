# frozen_string_literal: true

class Bank
  def initialize(player_account, diller_account)
    @player_account = player_account
    @diller_account = diller_account
    @bank_account = 0
  end

  def bet
    @player_account -= 10
    @diller_account -= 10
    @bank_account += 20
  end

  def players_account
    [@player_account, @diller_account]
  end

  def player_win
    give_gain(:@player_account)
    players_account
  end

  def diller_win
    give_gain(:@diller_account)
    players_account
  end

  def give_gain(account)
    @bank_account = 0
    instance_variable_set(account, instance_variable_get(account) + 20)
  end

  def draw
    @player_account += @bank_account / 2
    @diller_account += @bank_account / 2
    @bank_account = 0
    players_account
  end

  def positive_account?
    players_account.each do |account|
      return unless account.positive?
    end
  end

  private

  attr_accessor :bank_account, :player_account, :diller_account
end
