function _update()
  if debug.s == nil then
    debug.s = 0
  end
  debug.stack = p.action_stack
  debug.x = p.x
  debug.y = p.y

  for player in all(players) do
    p = player

    if not p.is_npc then
      update_frames_counter()
      update_previous_action()
      process_inputs()
      perform_current_action()
      perform_jumping()
    end
  end
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
        setup_action(actions.hook)
      else
        setup_action(actions.crouch)
      end
    elseif h⬆️ and not h🅾️❎ then
      if h⬅️ then
        setup_action(actions.jump, { direction = directions.backward })

        if p🅾️ then
          setup_action(actions.flying_punch)
        elseif p❎ then
          setup_action(actions.flying_kick)
        end
      elseif h➡️ then
        setup_action(actions.jump, { direction = directions.forward })

        if p🅾️ then
          setup_action(actions.flying_punch)
        elseif p❎ then
          setup_action(actions.flying_kick)
        end
      else
        setup_action(actions.jump)

        if p🅾️ then
          setup_action(actions.flying_punch)
        elseif p❎ then
          setup_action(actions.flying_kick)
        end
      end
    elseif h⬅️ and not h➡️ then
      if h🅾️❎ then
        setup_action(actions.block)
      elseif p🅾️ then
        setup_action(is_aerial() and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_action(is_aerial() and actions.flying_kick or actions.kick)
      else
        setup_action(actions.walk, { direction = directions.backward })
      end
    elseif h➡️ and not h⬅️ then
      if h🅾️❎ then
        setup_action(actions.block)
      elseif p🅾️ then
        setup_action(is_aerial() and actions.flying_punch or actions.punch)
      elseif p❎ then
        setup_action(is_aerial() and actions.flying_kick or actions.kick)
      else
        setup_action(actions.walk, { direction = directions.forward })
      end
    elseif h🅾️❎ then
      setup_action(actions.block)
    elseif p🅾️ then
      setup_action(is_aerial() and actions.flying_punch or actions.punch)
    elseif p❎ then
      setup_action(is_aerial() and actions.flying_kick or actions.kick)
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

function start_action(action, params, skip_record)
  if not skip_record then
    record_action(action, params)

    for k, special_move in pairs(p.character.special_moves) do
      local sequence = sub(p.action_stack, #p.action_stack - #special_move + 1, #p.action_stack)

      if sequence == special_move then
        return start_action(actions[k], {}, true)
      end
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
    if p.is_pixel_shifted == false then
      move_x(pixel_shift)
      p.is_pixel_shifted = true
    end
  end
end

function walk()
  move_x(0.5 * p.current_action_params.direction)
end

function move_x(x)
  p.x += x * p.facing
end

function move_y(y)
  p.y += y
end