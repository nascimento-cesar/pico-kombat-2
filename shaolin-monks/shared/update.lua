function get_combat_winner()
  local rounds_won = game.current_combat.rounds_won

  if rounds_won[p_id.p1] == 2 then
    return p1
  elseif rounds_won[p_id.p2] == 2 then
    return p2
  end
end

function get_vs(p)
  return p.id == p_id.p1 and p2 or p1
end

function has_combat_ended()
  return get_combat_winner() and true or false
end

function has_lost(p)
  return game.current_combat.round_loser == p
end

function init_player(p)
  game.joined_status[p.id] = true

  for i = 1, 12 do
    add(game.next_combats[p.id], i)
  end
end

function is_action_finished(p)
  return p.current_action_state == "finished"
end

function is_action_held(p)
  return p.current_action_state == "held"
end

function is_action_released(p)
  return p.current_action_state == "released"
end

function is_action_animation_finished(p)
  return p.frames_counter > p.current_action.frames_per_sprite * #p.current_action.sprites - 1
end

function is_aerial_attacking(p)
  return p.current_action.type == "aerial_attack"
end

function is_aerial(p)
  return p.current_action.type == "aerial"
end

function is_arcade_mode()
  return not is_playing(p1) or not is_playing(p2)
end

function is_attacking(p)
  return p.current_action_params.is_attacking
end

function is_limit_left(x)
  return x < 0
end

function is_limit_right(x)
  return x + sprite_w > 127
end

function is_moving(p)
  return p.current_action.type == "movement"
end

function is_p1_ahead_p2()
  local is_p1_ahead = p1.x > p2.x and p1.facing == directions.forward
  local is_p1_behind = p1.x + sprite_w < p2.x + sprite_w and p1.facing == directions.backward

  return is_p1_ahead or is_p1_behind
end

function is_playing(p)
  return game.joined_status[p.id]
end

function is_prone(p)
  return p.current_action == actions.prone
end

function is_propelled(p)
  return p.current_action == actions.propelled
end

function is_round_beginning()
  return game.current_combat.round_state == "countdown"
end

function is_round_finished()
  return game.current_combat.round_state == "finished"
end

function is_round_finishing_move()
  return game.current_combat.round_state == "finishing_move"
end

function is_round_in_progress()
  return game.current_combat.round_state == "in_progress"
end

function is_special_attacking(p)
  return p.current_action.type == "special_attack"
end

function player_has_joined()
  return game.current_combat.round_state == "new_player"
end

function update_debug()
  if debug.s == nil then
    debug.s = 0
  end
end