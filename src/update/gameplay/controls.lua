function process_inputs(p)
  local pressed_btns, pressed_directionals, direction = get_pressed_inputs(p)
  local pressed_combination, is_blocking, ac, input_candidate = pressed_directionals .. pressed_btns, pressed_btns == "🅾️❎"

  hold_or_release_inputs(p, pressed_btns, pressed_directionals)

  if not ac and p.released_btns then
    ac = get_ac_from_sequence(p)
  end

  if not ac and pressed_combination ~= "" then
    if is_blocking and p.held_btns then
      input_candidate = p.input_detection_delay <= 0 and pressed_directionals or ""
      ac = get_ac_from_sequence(p, input_candidate) or acs.block
    end

    if not ac then
      if not p.held_btns then
        input_candidate = pressed_combination
        ac = get_ac_from_input(p, input_candidate)
      end

      if not ac then
        if not p.held_btns then
          input_candidate = pressed_btns
          ac = get_ac_from_input(p, input_candidate)
        end

        if not ac then
          input_candidate = pressed_directionals
          ac = get_ac_from_input(p, input_candidate)

          if not ac and p.ca == acs.jump then
            record_ac(p, pressed_directionals)
          end
        end
      end
    end
  end

  if ac and input_candidate then
    record_ac(p, input_candidate)
  end

  setup_next_ac(p, ac and ac.name, direction and { direction = direction })
end

function get_ac_from_sequence(p, next_input)
  local ac, hdlr = nil, function(p, next_input, acs_list)
    for _, ac in pairs(acs_list) do
      local sequence, should_trigger = ac.sequence, false

      if (p.ca.is_aerial and ac.is_aerial) or (not p.ca.is_aerial and not ac.is_aerial) then
        if sub(sequence, 1, 1) == "h" and p.released_btns then
          local released_btns, released_btns_timer = unpack_split(p.released_btns)
          p.released_btns, should_trigger = nil, released_btns == sub(sequence, 3) and released_btns_timer >= sub(sequence, 2)
        else
          local command = p.ac_stack .. (p.ac_stack ~= "" and "+" or "") .. (next_input or "")
          should_trigger = sub(command, #command - #sequence + 1, #command) == sequence
        end
      end

      if should_trigger then
        return ac
      end
    end
  end

  if cb_round_state == "finishing_mv" then
    ac = hdlr(p, next_input, p.char.finishing_mvs)

    if ac then
      if (ac.name == "rp_f2" and p.st_timers.invisible <= 0) or (ac.name == "sz_f1_2" and not ccp.is_sz_f1_1_done) then
        ac = nil
      elseif ac.name == "sz_f1_1" then
        ac = p.char.special_atks.freeze
        ccp.is_sz_f1_1_done = true
      else
        ccp.finishing_mv = ac
        ac = acs.idle
      end
    end
  end

  if not ac then
    ac = hdlr(p, next_input, p.char.special_atks)
  end

  return ac
end

function get_ac_from_input(p, input_candidate)
  return get_ac_from_sequence(p, input_candidate) or acs[(p.ca.is_aerial and aerial_acs_map or ground_acs_map)[input_candidate]]
end

function get_pressed_inputs(p)
  local pressed_btns, pressed_directionals, direction = "", "", nil

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
        pressed_btns = pressed_btns .. k
      end
    end
  end

  if btnp(⬆️, p.id) and not p.ca.is_aerial and not p.ca.is_special_atk then
    pressed_directionals = pressed_directionals .. "⬆️"
  end

  if pressed_directionals == "➡️⬇️" or pressed_directionals == "⬅️⬇️" then
    pressed_directionals = "⬇️"
  end

  if p.ca == acs.block and pressed_btns ~= "🅾️❎" then
    pressed_btns = ""
  end

  return pressed_btns, pressed_directionals, direction
end

function hold_or_release_inputs(p, pressed_btns, pressed_directionals)
  if p.held_btns then
    if p.held_btns == pressed_btns then
      p.held_btns_timer += 1
    else
      release_held_btns(p)
    end
  elseif pressed_btns ~= "" then
    if p.held_btns_timer == 0 then
      if pressed_btns == p.previous_btns or not p.previous_btns then
        p.held_btns_timer += 1
      else
        p.held_btns_timer, p.previous_btns = 0, pressed_btns
      end
    else
      p.held_btns = pressed_btns
    end
  end

  if pressed_directionals ~= p.previous_directionals then
    p.input_detection_delay, p.previous_directionals = 0, pressed_directionals ~= "" and pressed_directionals or nil
  end
end

function release_held_btns(p)
  p.released_btns = (p.held_btns and p.held_btns_timer > 10)
      and p.held_btns .. "," .. flr(p.held_btns_timer / 10) or nil
  p.held_btns, p.held_btns_timer = nil, 0
end