function _update()
  update_debug()
  update_player(p1, p2)
  update_player(p2, p1)
  fix_orientation()
end

function update_player(p, vs)
  update_frames_counter(p)
  update_previous_action(p)

  if not p.is_npc then
    process_inputs(p)
  else
    handle_no_key_press(p)
  end

  perform_current_action(p, vs)
  update_aerial_action(p)
  update_projectile(p, vs)
end

function update_frames_counter(p)
  p.frames_counter += 1
end

function update_previous_action(p)
  if is_action_animation_finished(p) then
    if is_aerial(p) and not p.current_action_params.has_landed then
      restart_action(p)
    elseif is_aerial_attacking(p) and not p.current_action_params.has_landed then
      hold_action(p)
    elseif is_propelled(p) and not p.current_action_params.has_landed then
      hold_action(p)
    elseif is_special_attacking(p) then
      hold_action(p)
    else
      finish_action(p)
    end
  end
end

function process_inputs(p)
  local button_pressed = btn() > 0
  local h🅾️❎ = btn(🅾️) and btn(❎)
  local p🅾️ = btnp(🅾️)
  local p❎ = btnp(❎)
  local h⬆️ = btn(⬆️)
  local h⬇️ = btn(⬇️)
  local h⬅️ = btn(⬅️)
  local h➡️ = btn(➡️)

  if button_pressed then
    if h⬇️ then
      if h🅾️❎ then
        setup_action(p, actions.block)
      elseif p🅾️ then
        setup_attack(p, actions.hook)
      else
        setup_action(p, actions.crouch)
      end
    elseif h⬆️ and not h🅾️❎ then
      if h⬅️ then
        setup_action(p, actions.jump, { direction = p.facing * -1 })

        if p🅾️ then
          setup_attack(p, actions.flying_punch)
        elseif p❎ then
          setup_attack(p, actions.flying_kick)
        end
      elseif h➡️ then
        setup_action(p, actions.jump, { direction = p.facing })

        if p🅾️ then
          setup_attack(p, actions.flying_punch)
        elseif p❎ then
          setup_attack(p, actions.flying_kick)
        end
      else
        setup_action(p, actions.jump)

        if p🅾️ then
          setup_attack(p, actions.flying_punch)
        elseif p❎ then
          setup_attack(p, actions.flying_kick)
        end
      end
    elseif h⬅️ and not h➡️ then
      if h🅾️❎ then
        setup_action(p, actions.block)
      elseif p🅾️ then
        setup_attack(p, is_aerial(p) and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_attack(p, is_aerial(p) and actions.flying_kick or actions.kick)
      else
        setup_action(p, actions.walk, { direction = p.facing * -1 })
      end
    elseif h➡️ and not h⬅️ then
      if h🅾️❎ then
        setup_action(p, actions.block)
      elseif p🅾️ then
        setup_attack(p, is_aerial(p) and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_attack(p, is_aerial(p) and actions.flying_kick or actions.kick)
      else
        setup_action(p, actions.walk, { direction = p.facing })
      end
    elseif h🅾️❎ then
      setup_action(p, actions.block)
    elseif p🅾️ then
      setup_attack(p, is_aerial(p) and actions.flying_punch or actions.punch)
    elseif p❎ then
      setup_attack(p, is_aerial(p) and actions.flying_kick or actions.kick)
    else
      handle_no_key_press(p)
    end
  else
    handle_no_key_press(p)
  end
end

function perform_current_action(p, vs)
  return p.current_action.handler and p.current_action.handler(p, vs)
end

function update_aerial_action(p)
  if is_aerial(p) or is_aerial_attacking(p) or is_propelled(p) then
    local direction = p.current_action_params.direction
    local x_speed = jump_speed * (direction or 0) / 2
    local y_speed = jump_speed
    local has_changed_orientation = p.current_action_params.has_changed_orientation

    if p.current_action_params.is_landing then
      move_y(p, y_speed)
      move_x(p, x_speed, has_changed_orientation and p.facing * -1 or p.facing)

      if is_p1_ahead_p2() and not has_changed_orientation then
        if is_aerial(p) then
          p.current_action_params.has_changed_orientation = true
          shift_players_orientation()
        end
      end

      if p.y >= y_bottom_limit then
        p.is_orientation_locked = false
        p.current_action_params.has_landed = true
        p.current_action_params.is_landing = false
        setup_action(p, actions.idle)
      end
    else
      if not p.current_action_params.has_landed then
        p.is_orientation_locked = true
        move_y(p, -y_speed)
        move_x(p, x_speed)

        if p.y <= y_upper_limit then
          p.current_action_params.is_landing = true
        end
      end
    end
  end
end

function update_projectile(p, vs)
  if p.projectile then
    p.projectile.x += projectile_speed * p.facing
    p.projectile.frames_counter += 1

    if has_collision(p.projectile, vs) then
      p.projectile = nil
      start_action(p, actions.idle)
      deal_damage(vs)
    elseif is_limit_right(p.projectile) or is_limit_left(p.projectile) then
      p.projectile = nil
      start_action(p, actions.idle)
    end
  end
end

function fix_orientation()
  local is_orientation_locked = p1.is_orientation_locked or p2.is_orientation_locked

  if is_p1_ahead_p2() and not is_orientation_locked then
    if not is_aerial_attacking(p1) and not is_aerial_attacking(p2) then
      shift_players_orientation()
    end
  end
end

function shift_players_orientation()
  p1.facing *= -1
  p2.facing *= -1
end

function handle_no_key_press(p)
  if p.current_action == actions.walk then
    setup_action(p, actions.idle)
  elseif p.current_action.is_holdable and is_action_held(p) and not is_propelled(p) then
    setup_action(p, p.current_action, { is_released = true })
  elseif is_action_finished(p) then
    setup_action(p, actions.idle)
  end
end

function setup_action(p, next_action, params)
  params = params or {}

  if is_aerial(p) and next_action.type == action_types.aerial_attack then
    merge(params, p.current_action_params)
  end

  if is_action_finished(p) then
    if p.current_action == next_action then
      if p.current_action.is_holdable then
        hold_action(p)
      elseif is_moving(p) then
        restart_action(p)
      else
        start_action(p, next_action, params)
      end
    else
      start_action(p, next_action, params)
    end
  elseif p.current_action == next_action then
    if is_action_held(p) and params.is_released then
      release_action(p)
    elseif is_moving(p) and p.current_action_params.direction ~= params.direction then
      start_action(p, next_action, params)
    end
  elseif p.current_action ~= next_action then
    if is_aerial(p) then
      if next_action.type == action_types.aerial_attack or next_action == actions.idle then
        start_action(p, next_action, params)
      end
    elseif is_moving(p) then
      start_action(p, next_action, params)
    elseif is_action_held(p) then
      if not is_aerial_attacking(p) and not is_special_attacking(p) and next_action.type == action_types.attack then
        start_action(p, next_action, params)
      end
    end
  end
end

function setup_attack(p, next_action)
  setup_action(p, next_action, { is_attacking = true })
end

function start_action(p, action, params)
  record_action(p, action, params)

  for _, special_attack in pairs(p.character.special_attacks) do
    local current_sequence = sub(p.action_stack, #p.action_stack - #special_attack.sequence + 1, #p.action_stack)

    if current_sequence == special_attack.sequence then
      p.action_stack = ""

      return start_action(p, special_attack.action)
    end
  end

  p.current_action = action
  p.current_action_state = action_states.in_progress
  p.current_action_params = params
  p.frames_counter = 0
  shift_pixel(p, not action.is_pixel_shiftable)
end

function hold_action(p)
  p.current_action_state = action_states.held
  p.frames_counter = 0
end

function release_action(p)
  p.current_action_state = action_states.released
  p.current_action_params = { is_released = true }
  p.frames_counter = 0
end

function finish_action(p)
  p.current_action_state = action_states.finished
  shift_pixel(p, true)
end

function restart_action(p)
  p.current_action_state = action_states.in_progress
  p.frames_counter = 0
end

function has_collision(attacker, target, attacker_w, attacker_h)
  local attacker_w = attacker_w or sprite_w
  local attacker_h = attacker_h or sprite_h

  local horizontal_collision = attacker.x + attacker_w > target.x and attacker.x < target.x
  local vertical_collision = attacker.y + attacker_h > target.y

  return horizontal_collision and vertical_collision
end

function record_action(p, action, params)
  local key

  if action == actions.crouch then
    key = "⬇️"
  elseif action == actions.hook then
    key = "🅾️"
  elseif action == actions.jump then
    key = "⬆️"
  elseif action == actions.kick then
    key = "❎"
  elseif action == actions.punch then
    key = "🅾️"
  elseif action == actions.walk then
    key = params.direction == directions.forward and "➡️" or "⬅️"
  end

  if key then
    p.action_stack = p.action_stack .. key

    if #p.action_stack > 10 then
      p.action_stack = sub(p.action_stack, 2, 11)
    end
  end
end

function shift_pixel(p, unshift)
  if unshift then
    if p.is_pixel_shifted then
      move_x(p, -pixel_shift)
      p.is_pixel_shifted = false
    end
  else
    if not p.is_pixel_shifted and not is_limit_right(p) then
      move_x(p, pixel_shift)
      p.is_pixel_shifted = true
    end
  end
end

function fire_projectile(p)
  if not p.projectile then
    p.projectile = {
      frames_counter = 0,
      x = p.x + sprite_w * p.facing,
      y = p.y + 3
    }
  end
end

function deal_damage(p)
  p.hp -= 10
end

function react_to_damage(action, p)
  if action == actions.punch then
    flinch(p)
  elseif action == actions.kick then
    flinch(p)
  elseif action == actions.flying_punch then
    flinch(p)
  elseif action == actions.flying_kick then
    propelled(p)
  elseif action == actions.hook then
    propelled(p)
  end
end

function flinch(p)
  if p.current_action ~= actions.flinch then
    start_action(p, actions.flinch)
    move_x(p, -flinch_speed)
  end
end

function propelled(p)
  if not is_propelled(p) then
    start_action(p, actions.propelled, { direction = p.facing })
  end
end

function attack(p, vs)
  if p.current_action_params.is_attacking and has_collision(p, vs) then
    if vs.is_blocking then
    else
      deal_damage(vs)
      react_to_damage(p.current_action, vs)
      p.current_action_params.is_attacking = false
    end
  end
end

function walk(p)
  move_x(p, walk_speed * p.current_action_params.direction)
end

function update_debug()
  if debug.s == nil then
    debug.s = 0
  end

  debug.x = p1.x
  debug.y = p1.y

  if has_collision(p1, p2) then
    debug.collision = "true"
  else
    debug.collision = "false"
  end
end