function update_gameplay()
  if not stat(57) then
    music(0)
  end

  if cb_round_state == "boss_defeated" then
    return process_boss_defeated()
  end

  if detect_new_pl() then
    if not is_timer_active(cb_round_timers, "new_pl") then
      current_screen = "char_selection"
    end

    return
  end

  if cb_round_state == "in_progress" then
    cb_round_remaining_time = ceil(round_duration - (is_round_state_eq "starting" and 0 or time() - cb_round_start_time))

    if cb_round_remaining_time <= 0 then
      cb_round_state = "time_up"
    end
  end

  function_lookup("finished,finishing_mv,starting,time_up", { process_finished, process_finishing_mv, process_starting, process_time_up }, cb_round_state)

  if cb_round_state == "in_progress" then
    lock_controls(false, false)
  elseif cb_round_state == "finishing_mv" and not ccp.finishing_mv then
    lock_controls(p1 == cb_round_loser, p2 == cb_round_loser)
  else
    lock_controls(true, true)
  end

  update_pl(p1)
  update_pl(p2)
  fix_pls_orientation()
end

function build_prt_set(p, color, count, x, y, max_lifespan, radius)
  local max_lifespan, prt_set = max_lifespan or 10, string_to_hash("color,radius,prts,x,y", { color, radius, {}, x, y })

  for i = 1, count do
    add(
      prt_set.prts,
      string_to_hash(
        "current_lifespan,max_lifespan,speed_x,speed_y,x,y",
        { flr_rnd(max_lifespan), max_lifespan, rnd() * 2 - 1, rnd() * 2 - 1, prt_set.x, prt_set.y }
      )
    )
  end

  add(p.prt_sets, prt_set)
end

function detect_new_pl()
  foreach_pl(function(p, p_id)
    if not p.has_joined and not is_round_state_eq "new_pl" then
      if btnp(🅾️, p_id) or btnp(❎, p_id) then
        init_pl(p)
        cb_round_state = "new_pl"
      end
    end
  end)

  return is_round_state_eq "new_pl"
end

function process_boss_defeated()
  if is_timer_active(cb_round_timers, "boss_defeated", 240) then
    local timer, prt_function = cb_round_timers.boss_defeated, function(c, q, d, r)
      build_prt_set(cb_round_loser, c, q, cb_round_loser.x + flr_rnd(sp_w), cb_round_loser.y + flr_rnd(sp_h), d, r)
    end

    if timer > 180 then
      ccp.defeat_animation_step = 1
    elseif timer > 120 then
      if ccp.defeat_animation_step == 1 then
        play_sfx(43)
        setup_next_ac(cb_round_loser, "boss_defeated", nil, true)
        ccp.defeat_animation_step, cb_round_winner.x, cb_round_winner.y, cb_round_loser.x, cb_round_loser.y = 2, -20, -20, map_max_x / 2, y_bottom_limit
      end

      update_pl(cb_round_loser)

      if timer % 10 == 0 then
        prt_function(11, 6, max(20, flr_rnd(30)), flr_rnd(1))
        prt_function(3, 6, max(20, flr_rnd(30)), flr_rnd(1))
        prt_function(7, 3, max(20, flr_rnd(30)), flr_rnd(1))
      end
    elseif timer > 40 then
      if timer % 10 == 0 then
        prt_function(11, 4, max(20, flr_rnd(30)), max(2, flr_rnd(4)))
        prt_function(3, 4, max(20, flr_rnd(30)), max(2, flr_rnd(4)))
        prt_function(7, 2, max(20, flr_rnd(30)), flr_rnd(3))
      end
    elseif ccp.defeat_animation_step == 2 then
      play_sfx(42)
      prt_function(11, 8, 40, 6)
      prt_function(3, 8, 40, 3)
      prt_function(7, 8, 40, 6)
      ccp.defeat_animation_step, cb_round_loser.x, cb_round_loser.y = 3, -20, -20
    end
  elseif ccp.defeat_animation_step == 3 then
    if not is_timer_active(ccp, "congratulations_timer", 240) then
      _init()
    end
  end
end

function process_finishing_mv()
  local timer = is_timer_active(cb_round_timers, "finishing_mv")

  if ccp.finishing_mv then
    hdl_finishing_mv(cb_round_winner, cb_round_loser)
  elseif not timer then
    cb_round_state = "finished"
  else
    cb_round_loser.cap.next_ac = acs.dizzy
  end
end

function process_time_up()
  if not is_timer_active(cb_round_timers, "time_up") then
    cb_round_state = "finished"

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
  if cb_round_loser and cb_round_loser.y == y_bottom_limit then
    setup_next_ac(cb_round_loser, "fainted", nil, true)
  end

  if not is_timer_active(cb_round_timers, "finished") then
    local has_cb_ended, winner, loser = get_cb_result()

    if has_cb_ended then
      local main_pl = get_main_pl()
      current_screen = (not winner or loser.has_joined) and "char_selection" or "next_cb"

      if winner and main_pl == winner then
        deli(main_pl.next_cbs, 1)
      end
    else
      cb_round += 1
      cb_round_state = "starting"
      setup_new_round()
    end
  end
end

function process_starting()
  if not is_timer_active(cb_round_timers, "starting") then
    cb_round_remaining_time, cb_round_start_time, cb_round_state = round_duration, time(), "in_progress"
  end
end

function update_pl(p)
  local vs = get_vs(p)

  if cb_round_state ~= "finished" then
    is_timer_active(p.st_timers, "frozen")
    is_timer_active(p.st_timers, "invisible")

    if not is_timer_active(p.st_timers, "morphed") and p.is_morphed then
      p.char, p.is_morphed = chars[6], false
    end
  end

  if is_st_eq(p, "frozen") then
    return
  end

  p.t += 1
  update_frames_counter(p)
  resolve_previous_ac(p)

  if not p.has_locked_controls then
    if p.has_joined then
      process_inputs(p)
    else
      next_cpu_ac(p, vs)
    end
  end

  if p.ca.is_special_atk then
    hdl_special_atk(p)
  else
    hdl_ac(p)
  end

  if p.cap.reac_clb then
    p.cap.reac_clb(p, vs)
  end

  update_pj(p)

  if p.has_joined then
    cleanup_ac_stack(p)
  end
end