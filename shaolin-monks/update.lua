function _update()
  if debug.s == nil then
    debug.s = 0
  end

  for p in all(players) do
    debug.p_frames = p.rendering.frames_counter

    if not p.is_npc then
      update_frames_counter(p)
      update_previous_action_status(p)
      process_inputs(p)
      perform_current_action(p)
    end
  end
end

function update_frames_counter(p)
  p.rendering.frames_counter += 1
end

function update_previous_action_status(p)
  if is_current_action_finished(p) then
    p.current_action.is_finished = true
    shift_pixel(p, true)
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
        setup_action(actions.block, p)
      elseif p🅾️ then
        setup_action(actions.hook, p)
      else
        setup_action(actions.crouch, p)
      end
    elseif h⬆️ then
      setup_action(actions.jump, p)
    elseif h⬅️ and not h➡️ then
      if h🅾️❎ then
        setup_action(actions.block, p)
      elseif p🅾️ then
        setup_action(actions.punch, p)
      elseif p❎ then
        setup_action(actions.kick, p)
      else
        setup_action(actions.backward, p)
      end
    elseif h➡️ and not h⬅️ then
      if h🅾️❎ then
        setup_action(actions.block, p)
      elseif p🅾️ then
        setup_action(actions.punch, p)
      elseif p❎ then
        setup_action(actions.kick, p)
      else
        setup_action(actions.forward, p)
      end
    elseif h🅾️❎ then
      setup_action(actions.block, p)
    elseif p🅾️ then
      setup_action(actions.punch, p)
    elseif p❎ then
      setup_action(actions.kick, p)
    else
      handle_no_key_press(p)
    end
  else
    handle_no_key_press(p)
  end
end

function perform_current_action(p)
  local handler = action_handlers[p.current_action.action]
  return handler and handler(p)
end

function handle_no_key_press(p)
  if p.current_action.action.is_movement then
    setup_action(actions.idle, p)
  elseif p.current_action.action == actions.crouch and p.current_action.is_finished then
    setup_action(actions.stand, p)
  elseif p.current_action.action == actions.block and p.current_action.is_finished then
    setup_action(actions.unblock, p)
  elseif p.current_action.is_finished then
    setup_action(actions.idle, p)
  end
end

function setup_action(next_action, p)
  local previous_action = p.current_action.action
  local is_previous_action_finished = p.current_action.is_finished
  local should_trigger_action = false
  local is_action_held = previous_action == next_action and is_previous_action_finished and previous_action.is_holdable

  if is_previous_action_finished then
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
    p.current_action.action = next_action
    p.current_action.is_finished = false
    p.current_action.is_held = is_action_held
    p.rendering.frames_counter = 0
    shift_pixel(p, not next_action.is_pixel_shiftable)
  end
end

function is_current_action_finished(p)
  return p.rendering.frames_counter > p.current_action.action.frames_per_sprite * #p.current_action.action.sprites - 1
end

function shift_pixel(p, unshift)
  if unshift then
    if p.rendering.is_pixel_shifted then
      move_x(p, -general.pixel_shift)
      p.rendering.is_pixel_shifted = false
    end
  else
    if p.rendering.is_pixel_shifted == false then
      move_x(p, general.pixel_shift)
      p.rendering.is_pixel_shifted = true
    end
  end
end

function backward(p)
  move_x(p, -0.5)
end

function forward(p)
  move_x(p, 0.5)
end

function jump(p)
end

function jump_backward(p)
end

function jump_forward(p)
end

function crouch(p)
end

function punch(p)
end

function kick(p)
end

function hook(p)
end

function block(p)
end

function move_x(p, x)
  p.rendering.x += x * p.rendering.facing
end

function move_y(p, y)
  p.rendering.y += y
end