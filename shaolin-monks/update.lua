function _update()
  if debug.s == nil then
    debug.s = 0
  end
  update_frames_counter()
  update_previous_action_status()
  process_inputs()
  perform_current_action()
end

function update_frames_counter()
  player.rendering.frames_counter += 1
end

function update_previous_action_status()
  if is_current_action_finished() then
    player.current_action.is_finished = true
    shift_pixel(true)
  end
end

function process_inputs()
  local button_pressed = btn() > 0
  local block_pressed = btn(🅾️) and btn(❎)
  local punch_pressed = btn(🅾️)
  local kick_pressed = btn(❎)
  local crouch_pressed = btn(⬇️)
  local backward_pressed = btn(⬅️)
  local forward_pressed = btn(➡️)

  if button_pressed then
    if crouch_pressed then
      if punch_pressed then
        setup_action(actions.hook)
      else
        setup_action(actions.crouch)
      end
    elseif backward_pressed and not forward_pressed then
      if block_pressed then
        setup_action(actions.block)
      else
        setup_action(actions.backward)
      end
    elseif forward_pressed and not backward_pressed then
      if block_pressed then
        setup_action(actions.block)
      else
        setup_action(actions.forward)
      end
    end

    if block_pressed then
      setup_action(actions.block)
    else
      if punch_pressed then
        setup_action(actions.punch)
      end

      if kick_pressed then
        setup_action(actions.kick)
      end
    end
  else
    handle_no_key_press()
  end
end

function perform_current_action()
  local handler = action_handlers[player.current_action.action]
  return handler and handler()
end

function handle_no_key_press()
  if player.current_action.action.is_movement then
    setup_action(actions.idle)
  elseif player.current_action.action == actions.crouch and player.current_action.is_finished then
    setup_action(actions.stand)
  elseif player.current_action.action == actions.block and player.current_action.is_finished then
    setup_action(actions.unblock)
  elseif player.current_action.is_finished then
    setup_action(actions.idle)
  end
end

function setup_action(next_action)
  local previous_action = player.current_action.action
  local is_previous_action_finished = player.current_action.is_finished
  local should_trigger_action = false
  local is_action_held = previous_action == next_action and is_previous_action_finished and previous_action ~= actions.idle

  if is_previous_action_finished then
    debug.s += 1
    should_trigger_action = true
  elseif previous_action ~= next_action then
    if previous_action.is_movement then
      should_trigger_action = true
    elseif previous_action == actions.crouch and not next_action.is_movement then
      should_trigger_action = true
    elseif previous_action == actions.block and not next_action.is_movement then
      should_trigger_action = true
    end
  end

  if should_trigger_action then
    player.current_action.action = next_action
    player.current_action.is_finished = false
    player.current_action.is_held = is_action_held
    player.rendering.frames_counter = 0
    shift_pixel(not next_action.is_pixel_shiftable)
  end
end

function is_current_action_finished()
  return player.rendering.frames_counter > player.current_action.action.frames_per_sprite * #player.current_action.action.sprites - 1
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

function hook()
end

function block()
end

function unblock()
end

function move_x(x)
  player.rendering.x += x * player.rendering.facing
end