function process_inputs(p)
  local pressed_buttons, pressed_directionals, direction = get_pressed_inputs(p)
  local pressed_combination, is_blocking, action, input_candidate = pressed_directionals .. pressed_buttons, pressed_buttons == "🅾️❎"

  hold_or_release_inputs(p, pressed_buttons, pressed_directionals)

  if not action and p.released_buttons then
    action = get_action_from_sequence(p)
  end

  if not action and pressed_combination ~= "" then
    if is_blocking and p.held_buttons then
      input_candidate = p.input_detection_delay <= 0 and pressed_directionals or ""
      action = get_action_from_sequence(p, input_candidate) or actions.block
    end

    if not action then
      if not p.held_buttons then
        input_candidate = pressed_combination
        action = get_action_from_input(p, input_candidate)
      end

      if not action then
        if not p.held_buttons then
          input_candidate = pressed_buttons
          action = get_action_from_input(p, input_candidate)
        end

        if not action then
          input_candidate = pressed_directionals
          action = get_action_from_input(p, input_candidate)

          if not action and p.ca == actions.jump then
            record_action(p, pressed_directionals)
          end
        end
      end
    end
  end

  if action and input_candidate then
    record_action(p, input_candidate)
  end

  setup_next_action(p, action and action.name, direction and { direction = direction })
end

function get_action_from_sequence(p, next_input)
  local action, handler = nil, function(p, next_input, actions_list)
    for _, action in pairs(actions_list) do
      local sequence, should_trigger = action.sequence, false

      if (p.ca.is_aerial and action.is_aerial) or (not p.ca.is_aerial and not action.is_aerial) then
        if sub(sequence, 1, 1) == "h" and p.released_buttons then
          local released_buttons, released_buttons_timer = unpack_split(p.released_buttons)
          p.released_buttons, should_trigger = nil, released_buttons == sub(sequence, 3) and released_buttons_timer >= sub(sequence, 2)
        else
          local command = p.action_stack .. (p.action_stack ~= "" and "+" or "") .. (next_input or "")
          should_trigger = sub(command, #command - #sequence + 1, #command) == sequence
        end
      end

      if should_trigger then
        return action
      end
    end
  end

  if combat_round_state == "finishing_move" then
    action = handler(p, next_input, p.char.finishing_moves)

    if action then
      ccp.finishing_move = action
      action = actions.idle
    end
  end

  if not action then
    action = handler(p, next_input, p.char.special_attacks)
  end

  return action
end

function get_action_from_input(p, input_candidate)
  return get_action_from_sequence(p, input_candidate) or actions[(p.ca.is_aerial and aerial_actions_map or ground_actions_map)[input_candidate]]
end

function get_pressed_inputs(p)
  local pressed_buttons, pressed_directionals, direction = "", "", nil

  for i, k in ipairs(split "⬅️,➡️,⬆️,⬇️,🅾️,❎") do
    if btn(i - 1, p.id) then
      if i < 5 then
        if k ~= "⬆️" then
          if k == "⬅️" then
            direction = p.facing * -1
          elseif k == "➡️" then
            direction = p.facing
          end

          if p.facing == backward then
            k = k == "⬅️" and "➡️" or (k == "➡️" and "⬅️" or k)
          end

          pressed_directionals = pressed_directionals .. k
        end
      else
        pressed_buttons = pressed_buttons .. k
      end
    end
  end

  if btnp(⬆️, p.id) and not p.ca.is_aerial and not p.ca.is_special_attack then
    pressed_directionals = pressed_directionals .. "⬆️"
  end

  if pressed_directionals == "➡️⬇️" or pressed_directionals == "⬅️⬇️" then
    pressed_directionals = "⬇️"
  end

  if p.ca == actions.block and pressed_buttons ~= "🅾️❎" then
    pressed_buttons = ""
  end

  return pressed_buttons, pressed_directionals, direction
end

function hold_or_release_inputs(p, pressed_buttons, pressed_directionals)
  if p.held_buttons then
    if p.held_buttons == pressed_buttons then
      p.held_buttons_timer += 1
    else
      release_held_buttons(p)
    end
  elseif pressed_buttons ~= "" then
    if p.held_buttons_timer == 0 then
      if pressed_buttons == p.previous_buttons or not p.previous_buttons then
        p.held_buttons_timer += 1
      else
        p.held_buttons_timer, p.previous_buttons = 0, pressed_buttons
      end
    else
      p.held_buttons = pressed_buttons
    end
  end

  if pressed_directionals ~= p.previous_directionals then
    p.input_detection_delay, p.previous_directionals = 0, pressed_directionals ~= "" and pressed_directionals or nil
  end
end

function release_held_buttons(p)
  p.released_buttons = (p.held_buttons and p.held_buttons_timer > 10)
      and p.held_buttons .. "," .. flr(p.held_buttons_timer / 10) or nil
  p.held_buttons, p.held_buttons_timer = nil, 0
end