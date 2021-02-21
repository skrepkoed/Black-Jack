# frozen_string_literal: true

require_relative 'player'
class CurrentPlayer < Player
  attr_accessor :name

  def initialize
    super
  end
end
