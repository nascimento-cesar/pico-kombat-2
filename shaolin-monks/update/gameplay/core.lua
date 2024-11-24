function update_gameplay()
  if detect_new_player() then
    return process_new_player()
  end

  function_lookup("countdown,finished,finishing_move,new_player", { process_round_start, process_round_end, process_finishing_move }, combat_round_state)
  update_player(p1)
  update_player(p2)
  fix_players_orientation()
  fix_players_placement()
end

function build_particle_set(color, count, x, y)
  local particle_set = string_to_hash("color,particles,x,y", { color, {}, x, y })

  for i = 1, count do
    add(
      particle_set.particles,
      string_to_hash(
        "current_lifespan,max_lifespan,speed_x,speed_y,x,y",
        { rnd(10), 10, rnd() * 2 - 1, rnd() * 2 - 1, particle_set.x, particle_set.y }
      )
    )
  end

  return particle_set
end

function detect_new_player()
  foreach_player(function(p, p_id)
    if not p.has_joined and not is_round_state_eq "new_player" then
      if btnp(🅾️, p_id) or btnp(❎, p_id) then
        init_player(p)
        combat_round_state = "new_player"
      end
    end
  end)

  return is_round_state_eq "new_player"
end

function process_finishing_move()
  if not is_timer_active(combat_round_timers, "finishing_move") then
    combat_round_state = "finished"
  end
end

function process_new_player()
  if not is_timer_active(combat_round_timers, "new_player") then
    current_screen, p1.character, p2.character = "character_selection"
  end
end

function process_round_end()
  if not is_timer_active(combat_round_timers, "round_end") then
    if has_combat_ended() then
      local winner = get_combat_winner()
      local loser = get_vs(winner)

      if not p1.has_joined or not p2.has_joined then
        current_screen, loser.character = "next_combat"
      else
        current_screen, loser.character, winner.character = "character_selection"
      end
    else
      combat_round += 1
      combat_round_state = "countdown"
    end

    setup_new_round()
  end
end

function process_round_start()
  if not is_timer_active(combat_round_timers, "round_start") then
    combat_round_start_time, combat_round_state = time(), "in_progress"
  end
end

function reset_timers()
  for k, v in pairs(timers) do
    combat_round_timers[k] = v
  end
end

function update_player(p)
  update_st_timers(p)

  if is_st_eq(p, "frozen") then
    return
  end

  update_frames_counter(p)
  resolve_previous_action(p)

  if p.has_joined and not p.has_locked_controls then
    process_inputs(p)
  else
    next_cpu_action(p)
  end

  if p.ca.is_special_attack then
    handle_special_attack(p)
  else
    handle_action(p)
  end

  if p.cap.reaction_callback then
    p.cap.reaction_callback(p)
  end

  update_projectile(p)

  if p.has_joined then
    cleanup_action_stack(p)
  end
end

function update_st_timers(p)
  is_timer_active(p.st_timers, "frozen")
  is_timer_active(p.st_timers, "invisible")

  if not is_timer_active(p.st_timers, "morphed") and p.is_morphed then
    p.character = characters[6]
    p.is_morphed = false
  end
end