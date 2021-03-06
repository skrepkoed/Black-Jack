# frozen_string_literal: true

require_relative 'black_jack'
class TerminalInterface
  GAME = BlackJack
  def self.start
    new
  end

  def initialize
    @game_options = { player_draw_card: 'Draw card', pass: 'Pass', face_up: 'Face up',
                      win: 'You win!', lose: 'You lose!', draw: 'Draw.' }
    @game = GAME.new_game
    start_game
  end

  private

  attr_accessor :action, :game, :game_options

  def start_game
    clear_screen
    loop do
      current_action = send(*game.state)
      game.send current_action
    end
  rescue RuntimeError
    again?
  end

  def ask_name
    puts 'Enter your name:'
    :player_name
  end

  def current_hand(args)
    puts "Your hand: #{args[:player_hand]}"
    puts "Current score: #{args[:score]}"
    puts "Diller`s hand: #{args[:diller_hand]}"
    :limit_actions
  end

  def options(actions)
    puts 'Choose what you want to do next:'
    options = game_options.select { |action| actions.keys.include? action }.values
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i - 1
    action = actions.keys[input]
    clear_screen
    ensure_action(action)
  end

  def end_game(result, account, args)
    puts "Your hand: #{args[:player_hand]}"
    puts "Current score: #{args[:score]}"
    puts "Diller`s hand: #{args[:diller_hand]}"
    puts game_options[result] + current_account(account)
    raise RuntimeError
  end

  def current_account(account)
    "Your current account: #{account}"
  end

  def again?
    puts 'Would you like to try again? Y/N'
    if gets.chomp == 'Y'
      self.class.new
    else
      GAME.reset
      puts 'Goodbye'
    end
  end

  def ensure_action(action)
    if action
      action
    else
      puts 'Try again'
      current_hand
    end
  end

  def clear_screen
    puts "\e[H\e[2J"
  end
end
