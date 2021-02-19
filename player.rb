# frozen_string_literal: true

class Player
  attr_accessor :account, :hand

  def initialize(*_args)
    @account = 100
    @hand = []
  end

  def default
    @hand = []
  end
end
