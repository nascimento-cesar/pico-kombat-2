function process_inputs(p)
  local pressed_buttons, pressed_directionals, direction = get_pressed_inputs(p)
  local pressed_chord, actions_map, is_blocking, action_name, command_to_record = pressed_directionals .. pressed_buttons, (p.ca.is_aerial and aerial_actions_map or ground_actions_map), pressed_buttons == "🅾️❎"

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

  if is_blocking then
    command_to_record = pressed_directionals
    action_name = actions_map[pressed_buttons]
  else
    command_to_record = p.held_buttons and pressed_directionals or pressed_chord
    action_name = actions_map[command_to_record]

    if not action_name and not p.held_buttons then
      command_to_record = pressed_buttons ~= "" and pressed_buttons or pressed_directionals
      action_name = actions_map[command_to_record]
    end
  end

  if action_name and command_to_record then
    record_action(p, command_to_record)
  end

  setup_next_action(p, action_name, direction and { direction = direction })
end

function get_pressed_inputs(p)
  local pressed_buttons, pressed_directionals, direction = "", "", nil

  for i, k in ipairs(split "⬅️,➡️,⬆️,⬇️,🅾️,❎") do
    if btn(i - 1, p.id) then
      if i < 5 then
        if k == "⬅️" then
          direction = p.facing * -1
        elseif k == "➡️" then
          direction = p.facing
        end

        if p.facing == backward then
          k = k == "⬅️" and "➡️" or (k == "➡️" and "⬅️" or k)
        end

        pressed_directionals = pressed_directionals .. k
      else
        pressed_buttons = pressed_buttons .. k
      end
    end
  end

  return pressed_buttons, pressed_directionals, direction
end

function release_held_buttons(p)
  p.released_buttons = (p.held_buttons and p.held_buttons_timer > 10)
      and p.held_buttons .. "," .. flr(p.held_buttons_timer / 10) or nil
  p.held_buttons, p.held_buttons_timer = nil, 0
end