# frozen_string_literal: true

require_relative 'card'
class CardDeck
  attr_reader :cards

  def initialize
    @cards = []
  end

  def random_card
    add_card Card.random_card
    cards.last
  end

  def add_card(card)
    @cards = [] if cards.size == 52
    if cards.include? card
      random_card
    else
      cards << card
    end
  end
end
