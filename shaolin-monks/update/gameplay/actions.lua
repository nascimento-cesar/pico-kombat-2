function finish_action(p, next_action, next_action_params)
  p.cap.has_finished, next_action = true, next_action or (actions[p.ca.complementary_action] or actions.idle)
  start_action(p, next_action, next_action_params)
end

function aerial_action(p)
  local direction, vs, is_thrown_lower = p.cap.direction, get_vs(p), p.cap.is_thrown_lower
  local x_speed, is_turn_around_jump = (is_thrown_lower and offensive_speed or jump_speed) * (direction or 0) / 2, p.cap.is_turn_around_jump

  if p.cap.is_landing then
    if not is_thrown_lower or (is_thrown_lower and not is_timer_active(p.cap, "air_hold_frames", 4)) then
      move_y(p, jump_speed)
    end

    move_x(p, x_speed, is_turn_around_jump and p.facing * -1 or p.facing)

    if is_p1_ahead_p2() and not is_turn_around_jump then
      if not p.ca.is_attack then
        p.cap.is_turn_around_jump = true
        shift_player_orientation(p)
      end

      if not p.cap.vs_has_turned_around then
        shift_player_orientation(vs)
        p.cap.vs_has_turned_around = true
      end
    end

    if p.y >= y_bottom_limit then
      finish_action(p)
    end
  else
    move_y(p, -jump_speed)
    move_x(p, x_speed)

    if p.y <= (is_thrown_lower and y_upper_limit + 16 or y_upper_limit) then
      p.cap.is_landing = true
    end
  end
end

function cleanup_action_stack(p, force)
  if force or not is_timer_active(p, "action_stack_timeout") then
    p.action_stack_timeout = action_stack_timeout
    p.action_stack = ""
  end
end

function handle_action(p)
  local handler = p.ca.handler

  if handler == "attack" then
    attack(p)
  elseif handler == "flinch" then
    if is_timer_active(p.cap, "reaction_timer", p.ca.fps) then
      move_x(p, -walk_speed)
    end
  elseif handler == "jump" then
    aerial_action(p)
  elseif handler == "jump_attack" then
    aerial_action(p)
  elseif handler == "thrown_lower" then
    p.cap.direction = backward
    p.cap.is_thrown_lower = true
    aerial_action(p)
  elseif handler == "thrown_higher" then
    p.cap.direction = backward
    aerial_action(p)
  elseif handler == "swept" then
    if is_timer_active(p.cap, "reaction_timer", p.ca.fps) then
      move_x(p, -walk_speed)
    end
  elseif handler == "walk" then
    move_x(p, walk_speed * p.cap.direction)
  end
end

function hold_current_action(p)
  p.cap.is_held = true
end

function next_cpu_action(p)
end

function record_action(p, input)
  if p.input_detection_delay <= 0 and input ~= "" then
    p.action_stack = p.action_stack .. (p.action_stack ~= "" and "+" or "") .. input
    p.action_stack_timeout = action_stack_timeout
    p.input_detection_delay = 1

    if #p.action_stack > 20 then
      p.action_stack = sub(p.action_stack, 2, 21)
    end
  end
end

function release_current_action(p)
  p.cap.is_held = false
  p.cap.is_released = true
end

function reverse_current_action(p)
  p.cap.is_reversing = true
  set_current_action_animation_lock(p, false)
end

function set_current_action_animation_lock(p, lock)
  p.cap.is_animation_locked = lock
end

function resolve_previous_action(p)
  if p.cap.is_animation_complete and not p.cap.has_finished then
    if p.cap.is_held then
      return set_current_action_animation_lock(p, true)
    elseif p.ca.is_reversible and not p.cap.is_reversing then
      return reverse_current_action(p)
    elseif p.ca.is_resetable then
      return start_action(p, p.ca, p.cap)
    elseif p.ca.requires_forced_stop then
      return set_current_action_animation_lock(p, true)
    elseif p.ca.is_aerial and p.ca.is_special_attack then
      return finish_action(p, actions.jump, { is_landing = true, blocks_special_attacks = true })
    else
      return finish_action(p)
    end
  elseif p.cap.is_released then
    return set_current_action_animation_lock(p, false)
  end
end

function setup_next_action(p, action_name, params, force)
  local params, next_action = params or {}, detect_special_attack(p) or actions[action_name]

  if p.ca == next_action and p.ca.is_holdable and not p.cap.is_held then
    hold_current_action(p)
  elseif p.ca ~= next_action and p.cap.is_held then
    release_current_action(p)
  end

  if p.cap.has_finished or p.ca.is_cancelable or force then
    if next_action then
      if p.ca ~= next_action then
        return start_action(p, next_action, params)
      elseif next_action == actions.walk then
        return start_action(p, next_action, params, not p.cap.has_finished and p.cap.direction == params.direction)
      end
    elseif p.ca == actions.walk then
      return start_action(p, actions.idle)
    end
  elseif p.ca == actions.jump and next_action and next_action.is_aerial then
    if next_action.is_attack or (next_action.is_special_attack and not p.cap.blocks_special_attacks) then
      return start_action(p, next_action, p.cap)
    end
  end
end

function start_action(p, next_action, params, keep_current_frame)
  p.ca, p.cap, p.caf = next_action, params or {}, keep_current_frame and p.caf or 1
  p.cap.is_animation_complete = false
  shift_player_x(p, next_action.is_x_shiftable)
  shift_player_y(p, next_action.is_y_shiftable)
end