# frozen_string_literal: true

class Player
  attr_accessor :account, :hand, :current_points

  def initialize(*_args)
    @account = 100
    @hand = []
    @current_points = 0
  end
end
