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
    @current_player ||= CurrentPlayer.new
    @diller ||= Diller.new
    @bank ||= Bank.new(current_player.account, diller.account)
    if @bank.positive_account?
      new(@current_player, @diller, @bank, CardDeck.new)
    else
      reset
      new_game
    end
  end

  class << self
    attr_reader :current_player, :diller, :actions

    def reset
      @bank = nil
      @current_player = nil
      @diller = nil
    end
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
    @current_player.name ?  card_distribution : @state = :ask_name
  end

  private

  attr_accessor :current_player, :diller, :bank, :card_deck

  attr_writer :diller_hand, :player_hand

  def player_name
    current_player.name ||= gets.chomp
    card_distribution
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
    define_winner
  end

  def win
    current_player.account, diller.account = *bank.player_win
    self.state = [:end_game, :win, current_player.account]
  end

  def lose
    current_player.account, diller.account = *bank.diller_win
    self.state = [:end_game, :lose, current_player.account]
  end

  def draw
    current_player.account, diller.account = *bank.draw
    self.state = [:end_game, :draw, current_player.account]
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
