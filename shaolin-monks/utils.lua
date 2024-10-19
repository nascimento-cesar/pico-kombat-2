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

function is_special_attacking(p)
  return p.current_action.type == action_types.special_attack
end

function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end

function move_x(p, x)
  p.x += x * p.facing

  if is_limit_left(p) then
    p.x = 0
  elseif is_limit_right(p) then
    p.x = 127 - sprite_w
  end
end

function move_y(p, y)
  p.y += y
end