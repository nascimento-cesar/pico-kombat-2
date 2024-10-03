function _update()
  update_frames()
  update_current_action()
end

function update_current_action()
  check_idle_state()

  if player.is_action_locked == false then
    if btnp(5) then
      set_current_action(actions.kick)
    end

    if btnp(4) then
      set_current_action(actions.punch)
    end
  end
end

function update_frames()
  player.frames_counter += 1
end

function check_idle_state()
  if player.frames_counter >= player.current_action.f * #player.current_action.s - 1 then
    set_current_action(actions.idle)
  end
end

function set_current_action(action)
  if action != actions.idle then
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