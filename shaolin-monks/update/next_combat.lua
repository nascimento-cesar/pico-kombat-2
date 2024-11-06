function update_next_combat()
  for p in all({ p1, p2 }) do
    if not p.character then
      p.character = get_next_challenger(get_vs(p))
    end
  end

  game.current_combat = {
    current_stage = game.current_combat and game.current_combat.current_stage + 1 or 1,
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
  game.current_screen = "gameplay"
end