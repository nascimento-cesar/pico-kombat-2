function update_gameplay()
  if not stat(57) then
    music(0)
  end

  if detect_new_player() then
    return process_new_player()
  end

  update_round_timer()
  function_lookup("countdown,finished,finishing_move,time_up", { process_round_start, process_round_end, process_finishing_move, process_time_up }, combat_round_state)
  update_player(p1)
  update_player(p2)
  fix_players_orientation()
  fix_players_placement()
end

function update_round_timer()
  if combat_round_state == "in_progress" then
    combat_round_remaining_time = ceil(round_duration - (is_round_state_eq "countdown" and 0 or time() - combat_round_start_time))

    if combat_round_remaining_time <= 0 then
      combat_round_state = "time_up"
    end
  end
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
    current_screen = "character_selection"
  end
end

function process_time_up()
  lock_controls(true, true)

  if not is_timer_active(combat_round_timers, "time_up") then
    combat_round_state = "finished"

    if p1.hp > p2.hp then
      increment_rounds_won(p1)
    elseif p1.hp < p2.hp then
      increment_rounds_won(p2)
    else
      increment_rounds_won()
    end
  end
end

function process_round_end()
  lock_controls(true, true)

  if combat_round_loser then
    combat_round_loser.cap.next_action = actions.fainted
  end

  if not is_timer_active(combat_round_timers, "round_end") then
    local has_combat_ended, winner, loser = get_combat_result()

    if has_combat_ended then
      local main_player = get_main_player()
      current_screen = (not winner or loser.has_joined) and "character_selection" or "next_combat"

      if winner and main_player == winner then
        deli(main_player.next_combats, 1)
      end
    else
      combat_round += 1
      combat_round_state = "countdown"
      setup_new_round()
    end
  end
end

function process_round_start()
  if not is_timer_active(combat_round_timers, "round_start") then
    combat_round_remaining_time, combat_round_start_time, combat_round_state = round_duration, time(), "in_progress"
  end
end

function reset_timers()
  for k, v in pairs(timers) do
    combat_round_timers[k] = v
  end
end

function update_player(p)
  if combat_round_state ~= "finished" then
    update_st_timers(p)
  end

  if is_st_eq(p, "frozen") then
    return
  end

  p.t += 1
  update_frames_counter(p)
  resolve_previous_action(p)

  if not p.has_joined then
    next_cpu_action(p)
  elseif not p.has_locked_controls then
    process_inputs(p)
  end

  if p.ca.is_special_attack then
    handle_special_attack(p)
  else
    handle_action(p)
  end

  if p.cap.reaction_callback then
    p.cap.reaction_callback(p, get_vs(p))
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