function define_combat_variables(v)
  combat_round, combat_round_start_time, combat_round_remaining_time, combat_round_state, combat_round_winner, combat_rounds_won, combat_round_timers = unpack(v or {})
end

function get_combat_result()
  local p1_wins, p2_wins = combat_rounds_won[p1_id], combat_rounds_won[p2_id]

  if p1_wins >= 2 and p1_wins > p2_wins then
    return true, p1, p2
  elseif p2_wins >= 2 and p2_wins > p1_wins then
    return true, p2, p1
  elseif p2_wins == 2 and p1_wins == 2 then
    return true
  end

  return false
end

function get_main_player()
  if p1.has_joined and not p2.has_joined then
    return p1
  elseif not p1.has_joined and p2.has_joined then
    return p2
  end
end

function get_total_frames(p, cycles)
  return #p.ca.sprites * p.ca.fps * (cycles or 1)
end

function get_vs(p)
  return p.id == p1_id and p2 or p1
end

function init_player(p)
  p.has_joined = true
end

function is_boss(p)
  return p.character.name == "sk"
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
  return (p1.x > p2.x and p1.facing == forward) or (p1.x + sprite_w < p2.x + sprite_w and p1.facing == backward)
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

function increment_rounds_won(winner)
  if winner then
    combat_rounds_won[winner.id] += 1
    combat_round_winner, combat_round_loser = winner, get_vs(winner)
  else
    combat_rounds_won[p1.id] += 1
    combat_rounds_won[p2.id] += 1
    combat_round_winner, combat_round_loser = nil, nil
  end
end

function lock_controls(lock_p1, lock_p2)
  p1.has_locked_controls, p2.has_locked_controls = lock_p1, lock_p2
end

function setup_new_round()
  foreach_player(function(p, p_id)
    define_player(p_id, p)
  end)

  for k, v in pairs(round_timers) do
    combat_round_timers[k] = v
  end

  combat_round_remaining_time = round_duration
end

function update_frames_counter(p)
  if not p.cap.is_animation_locked then
    local prev, is_animation_complete, dmg_sprite_handler = p.caf, false, function(p)
      if p.ca.dmg_sprite then
        p.cap.is_dmg_sprite = not p.cap.is_reversing and p.caf > (p.ca.dmg_sprite - 1) * p.ca.fps and p.caf <= p.ca.dmg_sprite * p.ca.fps
      end
    end

    p.caf += p.cap.is_reversing and -1 or 1

    is_animation_complete = p.cap.is_reversing and p.caf <= 0 or p.caf > get_total_frames(p)

    dmg_sprite_handler(p)

    if is_animation_complete then
      p.caf = prev

      dmg_sprite_handler(p)

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