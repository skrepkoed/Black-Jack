# frozen_string_literal: true

require_relative 'player'
class Diller < Player
  def next_move(hands_score)
    if hands_score >= 17
      :pass
    else
      [:draw_card, self]
    end
  end
end
