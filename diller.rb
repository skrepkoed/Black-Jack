# frozen_string_literal: true

require_relative 'player'
class Diller < Player
  def next_move(hands_score)
    if hands_score >= 17
      :diller_pass
    else
      :diller_draw_card
    end
  end
end
