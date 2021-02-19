# frozen_string_literal: true

require_relative 'current_player'
require_relative 'diller'
require_relative 'bank'
require_relative 'card_deck'
class BlackJack
  CARD_POINTS = { J: 10, Q: 10, K: 10, A: 11 }.freeze

  def self.new_game
    puts 'Enter your name:'
    current_player = CurrnetPlayer.new(gets.chomp)
    new(current_player, Diller.new, Bank.new, CardDeck.new).game
  end

  attr_accessor :current_player, :diller, :bank, :card_deck

  def initialize(current_player, diller, bank, card_deck)
    @current_player = current_player
    @diller = diller
    @bank = bank
    @card_deck = card_deck
  end

  def game
    card_deck.distribute_cards(2, current_player.hand)
    card_deck.distribute_cards(2, diller.hand)
    current_hand
  end

  def current_hand
    puts "Your hand: #{current_player.hand.each { |card| print "#{card} " }}"
    puts "Current score: #{evaluate_hand(current_player.hand)}"
    puts "Diller`s hand: #{diller.hand.each { |_card| print '*' }}"
    options
  end

  def options
    puts 'Choose what you want to do next:'
    game_options = { 'Draw additional card' => :draw_card, 'Pass' => :pass, 'Face up' => :face_up }
    options = game_options.keys
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i
    send(game_options[options[input - 1]])
  end

  def draw_card
    card_deck.distribute_cards(1, current_player.hand)
    evaluate_hand(current_player.hand)
  end

  def pass; end

  def face_up
    puts "Your hand: #{current_player.hand.each { |card| print "#{card} " }}"
    puts "Diller`s hand: #{diller.hand.each { |card| print card.to_s }}"
    define_winner
  end

  def define_winner
    current_player_score = evaluate_hand(current_player.hand)
    diller_score = evaluate_hand(diller.hand)
    exceed_21?([current_player_score, diller_score])
    case current_player <=> diller_score
    when 1 then bank.give_gain(current_player)
    when 0 then bank.draw(current_player, diller)
    when -1 then bank.give_gain(diller)
    end
  end

  def exceed_21?(*hands_points)
    hands_points.each { |hand| hand > 21 ? (raise ExceedPoints) : false }
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
