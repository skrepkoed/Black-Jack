require_relative 'black_jack'
class TerminalInterface
  attr_accessor :action, :game

  def initialize
    @game = BlackJack.new_game
    start_game
  end

  def start_game
    loop do
      current_action = send game.state
      game.send current_action
    end
  end

  def ask_name
    puts 'Enter your name:'
    action = :player_name
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
end
