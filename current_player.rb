# frozen_string_literal: true

require_relative 'player'
class CurrentPlayer < Player
  attr_accessor :name

  def initialize(name)
    super
    @name = name
  end
end
