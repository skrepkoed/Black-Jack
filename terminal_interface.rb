require_relative 'black_jack'
require 'pry'
class TerminalInterface
  attr_accessor :action, :game, :game_options

  def initialize
    @game_options = { player_draw_card: 'Draw card', pass: 'Pass', face_up: 'Face up' }
    @game = BlackJack.new_game
    start_game
  end

  def start_game
    loop do
      current_action = send(*game.state)
      game.send current_action
    end
  end

  def ask_name
    puts 'Enter your name:'
    :player_name
  end

  def current_hand
    puts "Your hand: #{game.player_hand.report_hand}"
    puts "Current score: #{game.player_hand.evaluate}"
    puts "Diller`s hand: #{game.diller_hand.report_hand :hidden}"
    :limit_actions
  end

  def options(actions)
    puts 'Choose what you want to do next:'
    options = game_options.select { |action| actions.keys.include? action }.values
    (1..options.size).each { |number| puts "#{number}. #{options[number - 1]}" }
    input = gets.chomp.to_i - 1
    action = actions[game_options.keys[input]]
    clear_screen
    ensure_action(action)
  end

  def again?
    puts 'Would you like to try again? Y/N'
    input = gets.chomp
    BlackJack.new_game if input == 'Y'
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
