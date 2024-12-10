function finish_ac(p)
  p.cap.has_finished = true
  set_current_ac_animation_lock(p, false)
end

function aerial_ac(p)
  local direction, vs = p.cap.direction, get_vs(p)
  local x_speed, is_turn_around_jump = p.cap.x_speed or (jump_speed * (direction or 0) / 2), p.cap.is_turn_around_jump

  if p.ca == acs.propelled then
    x_speed *= 3
  end

  if p.cap.is_landing or p.ca == acs.fall then
    mv_x(p, x_speed, is_turn_around_jump and p.facing * -1 or p.facing)
    mv_y(p, jump_speed)

    if is_p1_ahd_p2() and not is_turn_around_jump then
      if not p.ca.is_atk then
        p.cap.is_turn_around_jump = true
        shift_pl_orientation(p)
      end

      if not p.cap.vs_has_turned_around then
        shift_pl_orientation(vs)
        p.cap.vs_has_turned_around = true
      end
    end

    if p.y >= y_bottom_limit then
      p.y = y_bottom_limit
      finish_ac(p)
    end
  else
    mv_y(p, -jump_speed)
    mv_x(p, x_speed)

    if p.y <= y_upper_limit then
      p.cap.is_landing = true
    end
  end
end

function cleanup_ac_stack(p, force)
  if force or not is_timer_active(p, "ac_stack_timeout") then
    p.ac_stack_timeout, p.ac_stack = ac_stack_timeout, ""
  end
end

function hdl_ac(p)
  local hdlr, vs = p.ca.hdlr, get_vs(p)

  if hdlr == "atk" then
    atk(p)
  elseif hdlr == "flinch" then
    if is_timer_active(p.cap, "reac_timer", p.ca.fps) then
      mv_x(p, -walk_speed)
    end
  elseif hdlr == "jump" or hdlr == "fall" then
    aerial_ac(p)
  elseif hdlr == "jump_atk" then
    aerial_ac(p)
    atk(p)
  elseif hdlr == "ouch" then
    if not is_timer_active(p.cap, "reac_timer", 30) then
      finish_ac(p)
    end
  elseif hdlr == "sweep" then
    if not vs.ca.is_aerial then
      atk(p)
    end
  elseif hdlr == "swept" then
    if is_timer_active(p.cap, "reac_timer", p.ca.fps) then
      mv_x(p, -walk_speed)
    end
  elseif hdlr == "thrown_backward" or hdlr == "propelled" then
    p.cap.direction = backward
    aerial_ac(p)
  elseif hdlr == "thrown_forward" then
    p.cap.direction = forward
    aerial_ac(p)
  elseif hdlr == "walk" then
    mv_x(p, walk_speed * p.cap.direction)
  end
end

function hold_current_ac(p)
  p.cap.is_held = true
end

function next_cpu_ac(p)
end

function record_ac(p, input)
  if p.input_detection_delay <= 0 and input ~= "" then
    p.ac_stack, p.ac_stack_timeout, p.input_detection_delay = p.ac_stack .. (p.ac_stack ~= "" and "+" or "") .. input, ac_stack_timeout, 1

    if #p.ac_stack > 20 then
      p.ac_stack = sub(p.ac_stack, 2, 21)
    end
  end
end

function release_current_ac(p)
  p.cap.is_held, p.cap.is_released = false, true
end

function set_current_ac_animation_lock(p, lock)
  p.cap.is_animation_locked = lock
end

function resolve_previous_ac(p)
  if p.cap.has_finished then
    if not p.ca.is_reversible or p.cap.is_reversed then
      start_ac(p, p.cap.next_ac or (acs[p.ca.complementary_ac] or acs.idle), p.cap.next_ac_params)
    end
  elseif p.cap.is_animation_complete then
    if p.cap.is_held then
      return set_current_ac_animation_lock(p, true)
    elseif p.ca.is_resetable then
      return start_ac(p, p.ca, p.cap, false, true)
    elseif p.ca.is_aerial and p.ca.is_special_atk then
      return setup_next_ac(p, "jump", { is_landing = true, blocks_aerial_acs = true }, true)
    elseif not p.ca.requires_forced_stop then
      return finish_ac(p)
    end
  elseif p.cap.is_reversing and p.cap.is_held then
    return set_current_ac_animation_lock(p, true)
  elseif p.cap.is_released then
    return set_current_ac_animation_lock(p, false)
  end
end

function setup_next_ac(p, ac_name, params, force)
  local params, next_ac = params or {}, acs[ac_name] or p.char.special_atks[ac_name]

  if p.ca == next_ac and p.ca.is_holdable and not p.cap.is_held then
    hold_current_ac(p)
  elseif p.ca ~= next_ac and p.cap.is_held then
    release_current_ac(p)
  end

  if p.cap.has_finished or p.ca.is_cancelable or force then
    if next_ac then
      if p.ca ~= next_ac then
        return start_ac(p, next_ac, params)
      elseif next_ac == acs.walk then
        return start_ac(p, next_ac, params, not p.cap.has_finished and p.cap.direction == params.direction)
      end
    elseif p.ca == acs.walk then
      return start_ac(p, acs.idle)
    end
  elseif p.ca == acs.jump and next_ac and next_ac.is_aerial then
    if (next_ac.is_atk or next_ac.is_special_atk) and not p.cap.blocks_aerial_acs then
      return start_ac(p, next_ac, p.cap)
    end
  end
end

function start_ac(p, next_ac, params, keep_current_frame, is_restarted)
  p.ca, p.cap, p.caf, p.t = next_ac, params or {}, keep_current_frame and p.caf or 1, is_restarted and p.t or 1
  p.cap.is_animation_complete = false
  shift_pl_x(p, p.cap.is_x_shiftable or next_ac.is_x_shiftable)
  shift_pl_y(p, p.cap.is_y_shiftable or next_ac.is_y_shiftable)
  set_current_ac_animation_lock(p, false)

  if next_ac.is_special_atk then
    cleanup_ac_stack(p, true)
  end

  if p.ca.ac_sfx and not is_restarted then
    play_sfx(p.ca.ac_sfx, 3)
  end
end