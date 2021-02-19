# frozen_string_literal: true

class Card
  attr_reader :suit, :rank

  Suits = { spade: 0x2660, heart: 0x2665, club: 0x2663, diamond: 0x2666 }.freeze
  Ranks = [*2..10, :J, :Q, :K, :A].freeze

  def self.random_card
    new(Ranks.sample, Suits.keys.sample)
  end

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank}#{(Suits[suit]).chr('UTF-8')}"
  end

  def ==(other)
    rank == other.rank && suit == other.suit ? true : false
  end
end
