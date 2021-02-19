# frozen_string_literal: true

require_relative 'current_player'
require_relative 'diller'
require_relative 'bank'
require_relative 'card_deck'
class BlackJack
  CARD_POINTS = { J: 10, Q: 10, K: 10, A: 11 }.freeze

  def self.new_game; end

  def initialize(current_player, diller, bank, card_deck)
    @current_player = current_player
    @diller = diller
    @bank = bank
    @card_deck = card_deck
  end

  def evaluate_hand(hand)
    ranks = hand.map(&:rank)
    points = ranks.map { |rank| define_card_point(rank) }.sum
    points -= 10 * (ranks.count { |rank| rank == :A } - 1) if points > 21 && hand.map(&:rank).include?(:A)
    points
  end

  def define_card_point(card_rank)
    CARD_POINTS[card_rank] || card_rank
  end
end
