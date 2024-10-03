function _update()
  update_frames_counter()
  finish_previous_action()
  handle_inputs()
  handle_current_action()
end

function handle_inputs()
  if player.is_action_locked == false then
    for input, handler in pairs(input_handlers) do
      if btn(input) then
        handler()
      end
    end
  end
end

function handle_current_action()
  local handler = action_handlers[player.current_action]
  return handler and handler()
end

function update_frames_counter()
  player.frames_counter += 1
end

function finish_previous_action()
  if is_current_action_finished() then
    if player.current_action == actions.crouch then
      if btn(⬇️) then
        -- set_current_action(actions.crouch)
      else
        set_current_action(actions.stand)
      end
    else
      set_current_action(actions.idle)
    end

    shift_pixel(true)
  end
end

function set_current_action(action, holdable)
  if action == player.current_action then
    return
  end

  if action.r then
    record_action(action)
    -- poke(0x5f5c, action.l and 255 or 0)
  end

  player.current_action = action
  player.frames_counter = 0
  player.is_action_locked = action.l or false
end

function record_action(action)
  add(actions_stack, action.i)

  if #actions_stack > 10 then
    deli(actions_stack, 1)
  end
end

function is_current_action_finished()
  return player.frames_counter > player.current_action.f * #player.current_action.s - 1
end

function handle_⬅️()
  set_current_action(actions.backward)
end

function handle_➡️()
  set_current_action(actions.forward)
end

function handle_⬇️()
  set_current_action(actions.crouch)
end

function handle_🅾️()
  set_current_action(actions.punch)
end

function handle_❎()
  set_current_action(actions.kick)
end

function handle_forward()
  move_x(0.5)
end

function handle_backward()
  move_x(-0.5)
end

function handle_crouch()
  -- player.x += 0.25 * player.direction
end

function handle_punch()
  shift_pixel()
end

function handle_kick()
  shift_pixel()
end

function shift_pixel(unshift)
  if unshift then
    if player.is_pixel_shifted then
      move_x(-pixel_shift)
      player.is_pixel_shifted = false
    end
  else
    if player.is_pixel_shifted == false then
      move_x(pixel_shift)
      player.is_pixel_shifted = true
    end
  end
end

function move_x(x)
  player.x += x * player.direction
end