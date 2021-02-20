# frozen_string_literal: true

require_relative 'current_player'
require_relative 'diller'
require_relative 'bank'
require_relative 'card_deck'
require_relative 'evaluation_score'
class BlackJack
  include EvaluationScore
  def self.new_game
    puts 'Enter your name:'
    @current_player = CurrentPlayer.new(gets.chomp)
    @diller = Diller.new
    set_new_game
    puts 'Goodbye!'
  end

  class << self
    attr_reader :current_player
  end

  def self.game_options
    @game_options['Draw additional card'] = [:draw_card, current_player]
    @game_options
  end

  @game_options = { 'Pass' => :pass,
                    'Face up' => :face_up }

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
    again?
  end

  def current_hand
    puts "Your hand: #{report_hand(current_player)}"
    puts "Current score: #{evaluate_hand(current_player.hand)}"
    puts "Diller`s hand: #{report_hand(diller, :hidden)}"
    options
  end

  def options
    puts 'Choose what you want to do next:'
    game_options = limit_actions(current_player, diller)
    game_options ||= BlackJack.game_options
    options = game_options.keys
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i
    action = game_options[options[input - 1]]
    clear_screen
    ensure_action(action)
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

  def report_hand(player, hidden = nil)
    if hidden
      player.hand.inject('') { |str, _card| "#{str}*" }
    else
      player.hand.inject('') { |str, card| str + "#{card} " }
    end
  end

  def win
    bank.give_gain(current_player)
    puts "You win! Your current account: #{current_player.account}"
  end

  def lose
    bank.give_gain(diller)
    puts "You lose! Your current account: #{current_player.account}"
  end

  def draw
    bank.draw(current_player, diller)
    puts "Draw. Your current account: #{current_player.account}"
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

  def limit_actions(player1, player2)
    if player1.hand.size == 3 || player2.hand.size == 3
      BlackJack.game_options.select do |option|
        option == 'Face up'
      end
    end
  end

  def again?
    puts 'Would you like to try again? Y/N'
    input = gets.chomp
    BlackJack.set_new_game if input == 'Y'
  end

  def ensure_action(action)
    if action
      send(*action)
    else
      puts 'Try again'
      current_hand
    end
  end

  def clear_screen
    puts "\e[H\e[2J"
  end
end
