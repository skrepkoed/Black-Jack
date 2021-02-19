# frozen_string_literal: true

class Bank
  attr_accessor :bank_account

  def initialize
    @bank_account = 0
  end

  def bet(*players)
    players.each do |player|
      player.account -= 10
      @bank_account += 10
    end
  end

  def give_gain(player)
    player.account += 20
    @bank_account = 0
  end

  def draw(player1, player2)
    player1.account += @bank_account / 2
    player2.account += @bank_account / 2
    @bank_account = 0
  end
end
