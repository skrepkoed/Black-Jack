# frozen_string_literal: true

module EvaluationScore
  def define_winner
    if draw?(player_hand, diller_hand)
      draw
    elsif !player_hand.exceed_21?
      calculate_score(player_hand.evaluate, diller_hand.evaluate)
    else
      lose
    end
  end

  def calculate_score(player1_score, player2_score)
    case (player1_score <=> player2_score) <=> (21 <=> player2_score)
    when 1 then win
    when 0 then win
    when -1 then lose
    end
  end

  def draw?(player1_score, player2_score)
    if player1_score.evaluate == player2_score.evaluate || player1_score.exceed_21? && player2_score.exceed_21?
      true
    else
      false
    end
  end
end
