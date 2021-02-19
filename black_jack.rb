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
    set_new_game
  end

  def self.set_new_game
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
    loop do
      card_deck.distribute_cards(2, current_player.hand)
      card_deck.distribute_cards(2, diller.hand)
      current_hand
      send(*diller.next_move)
      current_hand
      again?
    end
  end

  def current_hand
    puts "Your hand: #{current_player.hand.each { |card| print "#{card} " }}"
    puts "Current score: #{evaluate_hand(current_player.hand)}"
    puts "Diller`s hand: #{diller.hand.each { |_card| print '*' }}"
    options
  end

  def options
    puts 'Choose what you want to do next:'
    game_options = { 'Draw additional card' => [:draw_card, current_player],
                     'Pass' => :pass,
                     'Face up' => :face_up }
    game_options.delete 'Draw additional card' if current_player.hand.size == 3
    options = game_options.keys
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i
    send(game_options[*options[input - 1]])
  end

  def draw_card(player)
    card_deck.distribute_cards(1, player.hand)
    puts "Current score: #{evaluate_hand(current_player.hand)}"
    face_up if current_player.hand.size == 3
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
    if draw?(current_player, diller_score)
      bank.draw(current_player, diller)
      puts "Draw. Your current account: #{current_player.account}"
    else
      calculate_score(current_player, diller_score)
    end
  end

  def calculate_score(player1_score, player2_score)
    case player1_score <=> player2_score
    when 1
      bank.give_gain(current_player)
      puts "You win! Your current account: #{current_player.account}"
    when -1
      bank.give_gain(diller)
      puts "You lose! Your current account: #{current_player.account}"
    end
  end

  def draw?(player1_score, player2_score)
    if player1_score == player2_score || exceed_21?(player1_score) && exceed_21?(player2_score)
      true
    else
      false
    end
  end

  def exceed_21?(hands_points)
    hands_points > 21
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

  def again?
    puts 'Would you like to try again? Y/N'
    input = gets.chomp
    if input == 'Y'
      BlackJack.set_new_game
    else
      break
    end
  end
end
