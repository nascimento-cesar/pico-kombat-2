function update_next_combat()
  foreach_player(function(p, _, vs)
    if not vs.character then
      vs.character = get_next_challenger(p)
    end
  end)

  current_screen, current_combat = "gameplay", string_to_hash("current_stage,round,round_loser,round_start_time,round_state,round_winner,rounds_won,timers", { current_combat and current_combat.current_stage + 1 or 1, 1, nil, time(), "countdown", nil, { [p1_id] = 0, [p2_id] = 0 }, {} })
  reset_timers()
end