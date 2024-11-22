function define_combat_variables(v)
  combat_stage, combat_round, combat_round_loser, combat_round_start_time, combat_round_state, combat_round_winner, combat_rounds_won, combat_round_timers = unpack(v or {})
end

function get_combat_winner()
  if combat_rounds_won[p1_id] == 2 then
    return p1
  elseif combat_rounds_won[p2_id] == 2 then
    return p2
  end
end

function get_vs(p)
  return p.id == p1_id and p2 or p1
end

function has_combat_ended()
  return get_combat_winner() and true or false
end

function init_player(p)
  p.has_joined = true
end

function is_st_eq(p, st)
  return p.st_timers[st] > 0
end

function is_limit_left(x, tollerance)
  return x <= map_min_x - (tollerance or 0)
end

function is_limit_right(x, tollerance)
  return x + sprite_w > map_max_x + (tollerance or 0)
end

function is_p1_ahead_p2()
  local is_p1_ahead = p1.x > p2.x and p1.facing == forward
  local is_p1_behind = p1.x + sprite_w < p2.x + sprite_w and p1.facing == backward

  return is_p1_ahead or is_p1_behind
end

function is_round_state_eq(s)
  return combat_round_state == s
end

function is_timer_active(obj, timer, init_with)
  obj[timer] = obj[timer] or init_with

  if obj[timer] > 0 then
    obj[timer] -= 1
    return true
  end

  return false
end

function setup_new_round()
  foreach_player(function(p, p_id)
    define_player(p_id, p)
  end)
  reset_timers()
end

function update_frames_counter(p)
  if not p.cap.is_animation_locked then
    local prev, is_animation_complete = p.caf, false
    p.caf += p.cap.is_reversing and -1 or 1

    is_animation_complete = p.cap.is_reversing and p.caf <= 0 or p.caf > p.ca.fps * #p.ca.sprites

    if is_animation_complete then
      p.caf = prev

      if p.ca.requires_forced_stop and not p.cap.is_reversing then
        set_current_action_animation_lock(p, true)
      end

      if p.ca.is_reversible and not p.cap.is_reversing then
        p.cap.is_reversing = true
      else
        p.cap.is_animation_complete, p.cap.is_reversed = true, p.cap.is_reversing
      end
    end
  end
end

function update_debug()
  debug.p1_as = p1.action_stack

  if debug.s == nil then
    debug.s = 0
  end
end