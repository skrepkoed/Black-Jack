# frozen_string_literal: true

class Bank
  attr_reader :bank

  def initialize
    @bank = 0
  end

  def bet(player)
    player.account -= 10
    bank += 10
  end

  def give_gain(player)
    player.account += 20
    bank = 0
  end

  def draw(player1, player2)
    player1.account += bank / 2
    player2.account += bank / 2
    bank = 0
  end

  private

  attr_writer :bank
end
