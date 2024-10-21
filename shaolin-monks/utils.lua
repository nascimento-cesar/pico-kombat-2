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

function is_limit_left(obj)
  return obj.x <= 0
end

function is_limit_right(obj)
  return obj.x + sprite_w >= 127
end

function is_moving(p)
  return p.current_action.type == action_types.movement
end

function is_p1_ahead_p2()
  local is_p1_ahead = p1.x > p2.x and p1.facing == directions.forward
  local is_p1_behind = p1.x + sprite_w < p2.x + sprite_w and p1.facing == directions.backward

  return is_p1_ahead or is_p1_behind
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

function move_x(p, x, direction)
  direction = direction or p.facing

  p.x += x * direction

  if is_limit_left(p) then
    p.x = 0
  elseif is_limit_right(p) then
    p.x = 127 - sprite_w
  end
end

function move_y(p, y)
  p.y += y
end