function process_inputs(p)
  local pressed_buttons, pressed_directionals, direction = get_pressed_inputs(p)
  local pressed_combination, is_blocking, action_name, input_candidate = pressed_directionals .. pressed_buttons, pressed_buttons == "🅾️❎"

  hold_or_release_inputs(p, pressed_buttons, pressed_directionals)

  if p.released_buttons then
    action_name = detect_special_attack(p)
  end

  if not action_name and pressed_combination ~= "" then
    if is_blocking and p.held_buttons then
      input_candidate = p.input_detection_delay <= 0 and pressed_directionals or ""
      action_name = detect_special_attack(p, input_candidate) or "block"
    end

    if not action_name then
      if not p.held_buttons then
        input_candidate = pressed_combination
        action_name = get_action_from_input(p, input_candidate)
      end

      if not action_name then
        if not p.held_buttons then
          input_candidate = pressed_buttons
          action_name = get_action_from_input(p, input_candidate)
        end

        if not action_name then
          input_candidate = pressed_directionals
          action_name = get_action_from_input(p, input_candidate)

          if not action_name and p.ca == actions.jump then
            record_action(p, pressed_directionals)
          end
        end
      end
    end
  end

  if action_name and input_candidate then
    record_action(p, input_candidate)
  end

  setup_next_action(p, action_name, direction and { direction = direction })
end

function get_action_from_input(p, input_candidate)
  return detect_special_attack(p, input_candidate) or (p.ca.is_aerial and aerial_actions_map or ground_actions_map)[input_candidate]
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

  if btnp(⬆️, p.id) and not p.ca.is_aerial then
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