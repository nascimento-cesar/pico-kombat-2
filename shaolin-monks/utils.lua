function is_action_finished()
  return p.current_action_state == action_states.finished
end

function is_action_held()
  return p.current_action_state == action_states.held
end

function is_action_released()
  return p.current_action_state == action_states.released
end

function is_action_animation_finished()
  return p.frames_counter > p.current_action.frames_per_sprite * #p.current_action.sprites - 1
end

function is_aerial_attacking()
  return p.current_action.type == action_types.aerial_attack
end

function is_aerial()
  return p.current_action.type == action_types.aerial
end

function is_attacking()
  return p.current_action.type == action_types.attack
end

function is_limit_left(obj)
  return obj.x <= 0
end

function is_limit_right(obj)
  return obj.x + sprite_w >= 127
end

function is_moving()
  return p.current_action.type == action_types.movement
end

function is_special_attacking()
  return p.current_action.type == action_types.special_attack
end