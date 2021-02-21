# frozen_string_literal: true

module EvaluationScore
  def define_winner
    current_player_score = evaluate_hand(current_player.hand)
    diller_score = evaluate_hand(diller.hand)
    if draw?(current_player_score, diller_score)
      draw
    elsif !exceed_21?(current_player_score)
      calculate_score(current_player_score, diller_score)
    else
      lose
    end
    positive_account?(current_player, diller)
    raise RuntimeError
  end

  def calculate_score(player1_score, player2_score)
    case (player1_score <=> player2_score) <=> (21 <=> player2_score)
    when 1 then win
    when 0 then win
    when -1 then lose
    end
  end

  def draw?(player1_score, player2_score)
    if player1_score == player2_score || exceed_21?(player1_score) && exceed_21?(player2_score)
      true
    else
      false
    end
  end
end
