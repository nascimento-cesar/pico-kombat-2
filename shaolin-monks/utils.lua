function get_hcenter(s)
  return 64 - (s and #s or 0) * 2
end

function get_vcenter()
  return 61
end

function get_vs(p)
  return p.id == p1.id and p2 or p1
end

function is_action_finished(p)
  return p.current_action_state == action_states.finished
end

function is_action_held(p)
  return p.current_action_state == action_states.held
end

function is_action_released(p)
  return p.current_action_state == action_states.released
end

function is_action_animation_finished(p)
  return p.frames_counter > p.current_action.frames_per_sprite * #p.current_action.sprites - 1
end

function is_aerial_attacking(p)
  return p.current_action.type == action_types.aerial_attack
end

function is_aerial(p)
  return p.current_action.type == action_types.aerial
end

function is_limit_left(x)
  return x < 0
end

function is_limit_right(x)
  return x + sprite_w > 127
end

function is_moving(p)
  return p.current_action.type == action_types.movement
end

function is_p1_ahead_p2()
  local is_p1_ahead = p1.x > p2.x and p1.facing == directions.forward
  local is_p1_behind = p1.x + sprite_w < p2.x + sprite_w and p1.facing == directions.backward

  return is_p1_ahead or is_p1_behind
end

function is_prone(p)
  return p.current_action == actions.prone
end

function is_propelled(p)
  return p.current_action == actions.propelled
end

function is_special_attacking(p)
  return p.current_action.type == action_types.special_attack
end

function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end