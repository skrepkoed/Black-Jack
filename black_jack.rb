# frozen_string_literal: true

require_relative 'current_player'
require_relative 'diller'
require_relative 'bank'
require_relative 'card_deck'
require_relative 'evaluation_score'
require_relative 'hand'
class BlackJack
  include EvaluationScore
  def self.new_game
    @current_player = CurrentPlayer.new
    @diller = Diller.new
    @bank = Bank.new(current_player.account, diller.account)
    new(@current_player, @diller, @bank, CardDeck.new)
    # puts 'Goodbye!'
  end

  class << self
    attr_reader :current_player, :diller, :actions
  end

  @actions = { player_draw_card: :player_draw_card, pass: :pass, face_up: :face_up }

  attr_accessor :state
  attr_reader :diller_hand, :player_hand

  def initialize(current_player, diller, bank, card_deck)
    @current_player = current_player
    @diller = diller
    @bank = bank
    @card_deck = card_deck
    @diller_hand = Hand.new
    @player_hand = Hand.new
    @state = :ask_name
  end

  private

  attr_accessor :current_player, :diller, :bank, :card_deck

  attr_writer :diller_hand, :player_hand

  def player_name
    current_player.name ||= gets.chomp
    card_distribution
  end

  def game
    clear_screen
    card_deck.distribute_cards(2, current_player.hand)
    card_deck.distribute_cards(2, diller.hand)
    bank.bet(current_player, diller)
    current_hand ##
    send(*diller.next_move(evaluate_hand(diller.hand)))
    loop do
      break if current_hand
    end
    face_up
  rescue RuntimeError
    again?
  end

  def card_distribution
    player_hand.take_cards(2, card_deck)
    diller_hand.take_cards(2, card_deck)
    make_bet
  end

  def make_bet
    bank.bet
    self.state = :current_hand
  end

  def draw_card(hand)
    hand.take_cards(1, card_deck)
  end

  def player_draw_card
    draw_card(player_hand)
    diller_move
  end

  def diller_draw_card
    draw_card(diller_hand)
  end

  def diller_move
    send diller.next_move diller_hand.evaluate
    self.state = :current_hand
  end

  def diller_pass
    true
  end

  def pass
    diller_move
  end

  def face_up
    puts "Your hand: #{report_hand(current_player)}"
    puts "Diller`s hand: #{report_hand(diller)}"
    define_winner
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

  def limit_actions
    self.state = [:options]
    state << if player_hand.cards_amount == 3
               BlackJack.actions.select { |action, _argument| action == :face_up }
             else
               BlackJack.actions
             end
    state
  end
end
