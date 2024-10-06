function _update()
  update_frames_counter()
  update_previous_action_status()
  process_inputs()
  perform_current_action()
end

function process_inputs()
  local button_pressed = btn() > 0

  if button_pressed then
    if btn(🅾️) and btn(❎) then
    end

    if btnp(🅾️) then
      setup_action(actions.punch)
    end

    if btnp(❎) then
      setup_action(actions.kick)
    end

    if btn(⬅️) then
      setup_action(actions.backward)
    end

    if btn(➡️) then
      setup_action(actions.forward)
    end
  else
    setup_action(actions.idle)
  end
end

function perform_current_action()
  local handler = action_handlers[player.action.current]
  return handler and handler()
end

function update_frames_counter()
  player.rendering.frames_counter += 1
end

function update_previous_action_status()
  if is_current_action_finished() then
    player.action.is_finished = true
    shift_pixel(true)
  end
end

function setup_action(action)
  if player.action.is_finished or player.action.current.is_cancelable and action != player.action.previous then
    record_action(action)
    player.action.previous = player.action.current
    player.action.current = action
    player.action.is_finished = false
    player.rendering.frames_counter = 0
    shift_pixel(not action.is_pixel_shiftable)
  end
end

function record_action(action)
  if action.is_recordable then
    add(player.action.stack, action)

    if #player.action.stack > 5 then
      deli(player.action.stack, 1)
    end
  end
end

function is_current_action_finished()
  return player.rendering.frames_counter > player.action.current.frames_per_sprite * #player.action.current.sprites - 1
end

function forward()
  move_x(0.5)
end

function backward()
  move_x(-0.5)
end

function crouch()
end

function punch()
end

function kick()
end

function shift_pixel(unshift)
  if unshift then
    if player.rendering.is_pixel_shifted then
      move_x(-general.pixel_shift)
      player.rendering.is_pixel_shifted = false
    end
  else
    if player.rendering.is_pixel_shifted == false then
      move_x(general.pixel_shift)
      player.rendering.is_pixel_shifted = true
    end
  end
end

function move_x(x)
  player.rendering.x += x * player.rendering.facing
end