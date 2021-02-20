# frozen_string_literal: true

require 'pry'
require_relative 'current_player'
require_relative 'diller'
require_relative 'bank'
require_relative 'card_deck'
class BlackJack
  CardPoints = { J: 10, Q: 10, K: 10, A: 11 }.freeze

  def self.new_game
    puts 'Enter your name:'
    @current_player = CurrentPlayer.new(gets.chomp)
    @diller = Diller.new
    set_new_game
    puts 'Goodbye!'
  end

  def self.set_new_game
    [@current_player, @diller].map(&:default)
    new(@current_player, @diller, Bank.new, CardDeck.new)
  end

  def initialize(current_player, diller, bank, card_deck)
    @current_player = current_player
    @diller = diller
    @bank = bank
    @card_deck = card_deck
    game
  end

  private

  attr_accessor :current_player, :diller, :bank, :card_deck

  def game
    clear_screen
    card_deck.distribute_cards(2, current_player.hand)
    card_deck.distribute_cards(2, diller.hand)
    bank.bet(current_player, diller)
    current_hand
    send(*diller.next_move(evaluate_hand(diller.hand)))
    loop do
      break if current_hand
    end
    face_up
  rescue RuntimeError
    puts 'Would you like to try again? Y/N'
    input = gets.chomp
    BlackJack.set_new_game if input == 'Y'
  end

  def current_hand
    puts "Your hand: #{report_hand(current_player)}"
    puts "Current score: #{evaluate_hand(current_player.hand)}"
    puts "Diller`s hand: #{report_hand(diller, :hidden)}"
    options
  end

  def options
    puts 'Choose what you want to do next:'
    game_options = { 'Draw additional card' => [:draw_card, current_player],
                     'Pass' => :pass,
                     'Face up' => :face_up }
    game_options = { 'Face up' => :face_up } if current_player.hand.size == 3 || diller.hand.size == 3
    options = game_options.keys
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i
    action = game_options[options[input - 1]]
    clear_screen
    send(*action)
  end

  def draw_card(player)
    card_deck.distribute_cards(1, player.hand)
  end

  def pass
    true
  end

  def face_up
    puts "Your hand: #{report_hand(current_player)}"
    puts "Diller`s hand: #{report_hand(diller)}"
    define_winner
  end

  def define_winner
    current_player_score = evaluate_hand(current_player.hand)
    diller_score = evaluate_hand(diller.hand)
    if draw?(current_player_score, diller_score)
      bank.draw(current_player, diller)
      puts "Draw. Your current account: #{current_player.account}"
    elsif !exceed_21?(current_player_score)
      calculate_score(current_player_score, diller_score)
    else
      bank.give_gain(diller)
      puts "You lose! Your current account: #{current_player.account}"
    end
    positive_account?(current_player, diller)
    raise RuntimeError
  end

  def calculate_score(player1_score, player2_score)
    case (player1_score <=> player2_score) <=> (21 <=> player2_score)
    when 1
      bank.give_gain(current_player)
      puts "You win! Your current account: #{current_player.account}"
    when 0
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
    CardPoints[card_rank] || card_rank
  end

  def report_hand(player, hidden = nil)
    if hidden
      player.hand.inject('') { |str, _card| "#{str}*" }
    else
      player.hand.inject('') { |str, card| str + "#{card} " }
    end
  end

  def positive_account?(*players)
    players.each do |player|
      next if player.account.positive?

      puts 'Let`s try again'
      diller.account = 100
      current_player.account = 100
      raise RuntimeError
    end
  end

  def clear_screen
    puts "\e[H\e[2J"
  end
end
