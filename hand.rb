# frozen_string_literal: true

class Hand
  attr_reader :current_cards

  def initialize
    @current_cards = []
  end

  def take_cards(number, card)
    number.times { current_cards << card }
  end

  def report_hand(hidden = nil)
    if hidden
      current_cards.inject('') { |str, _card| "#{str}*" }
    else
      current_cards.inject('') { |str, card| str + "#{card} " }
    end
  end

  def exceed_21?
    evaluate > 21
  end

  def evaluate
    ranks = current_cards.map(&:rank)
    points = ranks.map { |rank| define_card_point(rank) }.sum
    points -= 10 * (ranks.count { |rank| rank == :A } - 1) if points > 21 && current_cards.map(&:rank).include?(:A)
    points
  end
end
