function is_action_finished(player)
  return player.current_action_state == action_states.finished
end

function is_action_held(player)
  return player.current_action_state == action_states.held
end

function is_action_released(player)
  return player.current_action_state == action_states.released
end

function is_action_animation_finished(player)
  return player.frames_counter > player.current_action.frames_per_sprite * #player.current_action.sprites - 1
end

function is_aerial_attacking(player)
  return player.current_action.type == action_types.aerial_attack
end

function is_aerial(player)
  return player.current_action.type == action_types.aerial
end

function is_limit_left(obj)
  return obj.x <= 0
end

function is_limit_right(obj)
  return obj.x + sprite_w >= 127
end

function is_moving(player)
  return player.current_action.type == action_types.movement
end

function is_special_attacking(player)
  return player.current_action.type == action_types.special_attack
end

function merge(obj1, obj2)
  for k, v in pairs(obj2) do
    obj1[k] = v
  end
end