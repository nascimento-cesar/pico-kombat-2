function _update()
  update_debug()
  update_player(p1, p2)
  update_player(p2, p1)
end

function update_player(player, versus)
  p = player
  vs = versus

  update_frames_counter()
  update_previous_action()

  if not p.is_npc then
    process_inputs()
  else
    setup_action(actions.idle)
  end

  perform_current_action()
  perform_jumping()
  update_projectile()
end

function update_frames_counter()
  p.frames_counter += 1
end

function update_previous_action()
  if is_action_animation_finished() then
    if is_aerial() and not p.current_action_params.has_landed then
      restart_action()
    elseif is_aerial_attacking() and not p.current_action_params.has_landed then
      hold_action()
    elseif is_special_attacking() then
      hold_action()
    else
      finish_action()
    end
  end
end

function process_inputs()
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
        setup_action(actions.block)
      elseif p🅾️ then
        setup_attack(actions.hook)
      else
        setup_action(actions.crouch)
      end
    elseif h⬆️ and not h🅾️❎ then
      if h⬅️ then
        setup_action(actions.jump, { direction = p.facing * -1 })

        if p🅾️ then
          setup_attack(actions.flying_punch)
        elseif p❎ then
          setup_attack(actions.flying_kick)
        end
      elseif h➡️ then
        setup_action(actions.jump, { direction = p.facing })

        if p🅾️ then
          setup_attack(actions.flying_punch)
        elseif p❎ then
          setup_attack(actions.flying_kick)
        end
      else
        setup_action(actions.jump)

        if p🅾️ then
          setup_attack(actions.flying_punch)
        elseif p❎ then
          setup_attack(actions.flying_kick)
        end
      end
    elseif h⬅️ and not h➡️ then
      if h🅾️❎ then
        setup_action(actions.block)
      elseif p🅾️ then
        setup_attack(is_aerial() and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_attack(is_aerial() and actions.flying_kick or actions.kick)
      else
        setup_action(actions.walk, { direction = p.facing * -1 })
      end
    elseif h➡️ and not h⬅️ then
      if h🅾️❎ then
        setup_action(actions.block)
      elseif p🅾️ then
        setup_attack(is_aerial() and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_attack(is_aerial() and actions.flying_kick or actions.kick)
      else
        setup_action(actions.walk, { direction = p.facing })
      end
    elseif h🅾️❎ then
      setup_action(actions.block)
    elseif p🅾️ then
      setup_attack(is_aerial() and actions.flying_punch or actions.punch)
    elseif p❎ then
      setup_attack(is_aerial() and actions.flying_kick or actions.kick)
    else
      handle_no_key_press()
    end
  else
    handle_no_key_press()
  end
end

function perform_current_action()
  return p.current_action.handler and p.current_action.handler()
end

function perform_jumping()
  if is_aerial() or is_aerial_attacking() then
    local x_speed = jump_speed * (p.current_action_params.direction or 0) / 2
    local y_speed = jump_speed

    if p.current_action_params.is_landing then
      move_y(y_speed)
      move_x(x_speed)

      if p.y >= y_bottom_limit then
        p.current_action_params.has_landed = true
        p.current_action_params.is_landing = false
        setup_action(actions.idle)
      end
    else
      if not p.current_action_params.has_landed then
        move_y(-y_speed)
        move_x(x_speed)

        if p.y <= y_upper_limit then
          p.current_action_params.is_landing = true
        end
      end
    end
  end
end

function update_projectile()
  if p.projectile then
    p.projectile.x += projectile_speed * p.facing
    p.projectile.frames_counter += 1

    if is_limit_right(p.projectile) or is_limit_left(p.projectile) then
      p.projectile = nil
      start_action(actions.idle)
    end
  end
end

function handle_no_key_press()
  if p.current_action == actions.walk then
    setup_action(actions.idle)
  elseif p.current_action.is_holdable and is_action_held() then
    setup_action(p.current_action, { is_released = true })
  elseif is_action_finished() then
    setup_action(actions.idle)
  end
end

function setup_action(next_action, params)
  params = params or {}

  if is_aerial() and next_action.type == action_types.aerial_attack then
    params = p.current_action_params
  end

  if is_action_finished() then
    if p.current_action == next_action then
      if p.current_action.is_holdable then
        hold_action()
      elseif is_moving() then
        restart_action()
      else
        start_action(next_action, params)
      end
    else
      start_action(next_action, params)
    end
  elseif p.current_action == next_action then
    if is_action_held() and params.is_released then
      release_action()
    elseif is_moving() and p.current_action_params.direction ~= params.direction then
      start_action(next_action, params)
    end
  elseif p.current_action ~= next_action then
    if is_aerial() then
      if next_action.type == action_types.aerial_attack or next_action == actions.idle then
        start_action(next_action, params)
      end
    elseif is_moving() then
      start_action(next_action, params)
    elseif is_action_held() then
      if not is_aerial_attacking() and not is_special_attacking() and next_action.type == action_types.attack then
        start_action(next_action, params)
      end
    end
  end
end

function setup_attack(next_action)
  setup_action(next_action, { is_attacking = true })
end

function start_action(action, params)
  record_action(action, params)

  for _, special_attack in pairs(p.character.special_attacks) do
    local current_sequence = sub(p.action_stack, #p.action_stack - #special_attack.sequence + 1, #p.action_stack)

    if current_sequence == special_attack.sequence then
      p.action_stack = ""

      return start_action(special_attack.action, {})
    end
  end

  p.current_action = action
  p.current_action_state = action_states.in_progress
  p.current_action_params = params
  p.frames_counter = 0
  shift_pixel(not action.is_pixel_shiftable)
end

function hold_action()
  p.current_action_state = action_states.held
  p.frames_counter = 0
end

function release_action()
  p.current_action_state = action_states.released
  p.current_action_params = { is_released = true }
  p.frames_counter = 0
end

function finish_action()
  p.current_action_state = action_states.finished
  shift_pixel(true)
end

function restart_action()
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

function record_action(action, params)
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

function shift_pixel(unshift)
  if unshift then
    if p.is_pixel_shifted then
      move_x(-pixel_shift)
      p.is_pixel_shifted = false
    end
  else
    if not p.is_pixel_shifted and not is_limit_right(p) then
      move_x(pixel_shift)
      p.is_pixel_shifted = true
    end
  end
end

function fire_projectile()
  if not p.projectile then
    p.projectile = {
      frames_counter = 0,
      x = p.x + sprite_w * p.facing,
      y = p.y + 3
    }
  end
end

function attack()
  if p.current_action_params.is_attacking and has_collision(p, vs) then
    if vs.is_blocking then
    else
      vs.hp -= 10
      p.current_action_params.is_attacking = false
    end
  end
end

function walk()
  move_x(walk_speed * p.current_action_params.direction)
end

function move_x(x)
  p.x += x * p.facing

  if is_limit_left(p) then
    p.x = 0
  elseif is_limit_right(p) then
    p.x = 127 - sprite_w
  end
end

function move_y(y)
  p.y += y
end

function update_debug()
  if debug.s == nil then
    debug.s = 0
  end
  debug.x = p1.x
  debug.y = p1.y

  if has_collision(p1, p2) then
    debug.hit = "true"
  else
    debug.hit = "false"
  end

  debug.attacking = p1.is_attacking and 'true' or 'false'
end