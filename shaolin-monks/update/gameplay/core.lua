function update_gameplay()
  if not stat(57) then
    music(0)
  end

  if combat_round_state == "boss_defeated" then
    return process_boss_defeated()
  end

  if detect_new_player() then
    if not is_timer_active(combat_round_timers, "new_player") then
      current_screen = "character_selection"
    end

    return
  end

  if combat_round_state == "in_progress" then
    combat_round_remaining_time = ceil(round_duration - (is_round_state_eq "starting" and 0 or time() - combat_round_start_time))

    if combat_round_remaining_time <= 0 then
      combat_round_state = "time_up"
    end
  end

  function_lookup("finished,finishing_move,starting,time_up", { process_finished, process_finishing_move, process_starting, process_time_up }, combat_round_state)

  if combat_round_state == "in_progress" then
    lock_controls(false, false)
  elseif combat_round_state == "finishing_move" then
    lock_controls(p1 == combat_round_loser, p2 == combat_round_loser)
  else
    lock_controls(true, true)
  end

  update_player(p1)
  update_player(p2)
  fix_players_orientation()
end

function build_particle_set(p, color, count, x, y, max_lifespan, radius)
  local max_lifespan, particle_set = max_lifespan or 10, string_to_hash("color,radius,particles,x,y", { color, radius, {}, x, y })

  for i = 1, count do
    add(
      particle_set.particles,
      string_to_hash(
        "current_lifespan,max_lifespan,speed_x,speed_y,x,y",
        { flr_rnd(max_lifespan), max_lifespan, rnd() * 2 - 1, rnd() * 2 - 1, particle_set.x, particle_set.y }
      )
    )
  end

  add(p.particle_sets, particle_set)
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

function process_boss_defeated()
  if is_timer_active(combat_round_timers, "boss_defeated", 240) then
    local timer, particle_function = combat_round_timers.boss_defeated, function(c, q, d, r)
      build_particle_set(combat_round_loser, c, q, combat_round_loser.x + flr_rnd(sprite_w), combat_round_loser.y + flr_rnd(sprite_h), d, r)
    end

    if timer > 180 then
      temp.defeat_animation_step = 1
    elseif timer > 120 then
      if temp.defeat_animation_step == 1 then
        setup_next_action(combat_round_loser, "boss_defeated", nil, true)
        temp.defeat_animation_step, combat_round_winner.x, combat_round_winner.y, combat_round_loser.x, combat_round_loser.y = 2, -20, -20, map_max_x / 2, y_bottom_limit
      end

      update_player(combat_round_loser)

      if timer % 10 == 0 then
        particle_function(11, 6, max(20, flr_rnd(30)), flr_rnd(1))
        particle_function(3, 6, max(20, flr_rnd(30)), flr_rnd(1))
        particle_function(7, 3, max(20, flr_rnd(30)), flr_rnd(1))
      end
    elseif timer > 40 then
      if timer % 10 == 0 then
        particle_function(11, 4, max(20, flr_rnd(30)), max(2, flr_rnd(4)))
        particle_function(3, 4, max(20, flr_rnd(30)), max(2, flr_rnd(4)))
        particle_function(7, 2, max(20, flr_rnd(30)), flr_rnd(3))
      end
    elseif temp.defeat_animation_step == 2 then
      particle_function(11, 8, 40, 6)
      particle_function(3, 8, 40, 3)
      particle_function(7, 8, 40, 6)
      temp.defeat_animation_step, combat_round_loser.x, combat_round_loser.y = 3, -20, -20
    end
  elseif temp.defeat_animation_step == 3 then
    if not is_timer_active(temp, "congratulations", 240) then
      _init()
    end
  end
end

function process_finishing_move()
  if not is_timer_active(combat_round_timers, "finishing_move") then
    combat_round_state = "finished"
  end
end

function process_time_up()
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

function process_finished()
  if combat_round_loser then
    combat_round_loser.cap.next_action = actions.fainted
  end

  if not is_timer_active(combat_round_timers, "finished") then
    local has_combat_ended, winner, loser = get_combat_result()

    if has_combat_ended then
      local main_player = get_main_player()
      current_screen = (not winner or loser.has_joined) and "character_selection" or "next_combat"

      if winner and main_player == winner then
        deli(main_player.next_combats, 1)
      end
    else
      combat_round += 1
      combat_round_state = "starting"
      setup_new_round()
    end
  end
end

function process_starting()
  if not is_timer_active(combat_round_timers, "starting") then
    combat_round_remaining_time, combat_round_start_time, combat_round_state = round_duration, time(), "in_progress"
  end
end

function update_player(p)
  if combat_round_state ~= "finished" then
    is_timer_active(p.st_timers, "frozen")
    is_timer_active(p.st_timers, "invisible")

    if not is_timer_active(p.st_timers, "morphed") and p.is_morphed then
      p.character, p.is_morphed = characters[6], false
    end
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