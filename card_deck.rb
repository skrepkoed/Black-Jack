# frozen_string_literal: true

require_relative 'card'
class CardDeck
  attr_reader :cards

  def initialize
    @cards = []
  end

  def random_card
    add_card Card.new(Card::RANKS.sample, Card::SUITS.keys.sample)
  end

  def add_card(card)
    cards << card unless cards.include? card
  end
end
