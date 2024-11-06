function update_next_combat()
  foreach_player(function(p, _, vs)
    if not vs.character then
      vs.character = get_next_challenger(p)
    end
  end)

  current_combat = {
    current_stage = current_combat and current_combat.current_stage + 1 or 1,
    round = 1,
    round_loser = nil,
    round_start_time = time(),
    round_state = "countdown",
    round_winner = nil,
    rounds_won = {
      [p1_id] = 0,
      [p2_id] = 0
    },
    timers = {}
  }

  reset_timers()
  current_screen = "gameplay"
end