function _update()
  update_frames_counter()
  update_current_action_status()
  handle_inputs()
  -- handle_next_action()
end

function handle_inputs()
  for input, handler in pairs(input_handlers) do
    if btn(input) then
      handler()
    end
  end
end

function handle_next_action()
  local handler = action_handlers[player.action.current]
  return handler and handler()
end

function update_frames_counter()
  player.rendering.frames_counter += 1
end

function update_current_action_status()
  player.action.is_finished = is_current_action_finished()
end

function process_movement(action)
end

function process_action(action)
  if player.action.is_finished or player.action.current.is_cancelable then
    if action.is_recordable then
      record_action(action)
    end

    unshift_pixel()
    player.action.current = action
    player.action.is_finished = false
    player.action.is_held = false
    player.rendering.frames_counter = 0
  end
end

-- function finish_previous_action()
--   if is_current_action_finished() then
--     if player.current_action == actions.crouch then
--       set_current_action(actions.stand)
--     else
--       set_current_action(actions.idle)
--     end

--     shift_pixel(true)
--   end
-- end

-- function set_current_action(action)
--   if action == player.current_action and action.h then
--     player.is_action_held = action.h

--     return
--   end

--   if action.r then
--     record_action(action)
--     -- poke(0x5f5c, action.l and 255 or 0)
--   end

--   shift_pixel(true)
--   player.current_action = action
--   player.frames_counter = 0
--   player.is_action_held = false
--   player.is_action_locked = action.l or false
-- end

function record_action(action)
  add(player.action.stack, action)

  if #player.action.stack > 5 then
    deli(player.action.stack, 1)
  end
end

function is_current_action_finished()
  return player.rendering.frames_counter > player.action.current.frames_per_sprite * #player.action.current.sprites - 1
end

function handle_⬅️()
end

function handle_➡️()
end

function handle_⬇️()
end

function handle_🅾️()
  process_action(actions.kick)
end

function handle_❎()
  process_action(actions.punch)
end

function handle_forward()
  -- move_x(0.5)
end

function handle_backward()
  -- move_x(-0.5)
end

function handle_crouch()
end

function handle_punch()
  -- shift_pixel()
end

function handle_kick()
  -- shift_pixel()
end

function shift_pixel()
  if not player.rendering.is_pixel_shifted then
    move_x(general.pixel_shift)
    player.rendering.is_pixel_shifted = true
  end
end

function unshift_pixel()
  if player.rendering.is_pixel_shifted then
    move_x(-general.pixel_shift)
    player.rendering.is_pixel_shifted = false
  end
end

function move_x(x)
  player.rendering.x += x * player.rendering.facing
end