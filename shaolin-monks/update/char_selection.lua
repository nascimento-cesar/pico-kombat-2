function update_char_selection()
  music(-1, 200)

  if ccp.chars_selected and not is_timer_active(ccp, "round_beginning_timer", 30) then
    p1.temp_char, p2.temp_char, ccp.chars_selected, current_screen = nil, nil, false, "next_cb"
  else
    foreach_player(handle_cursor_movement)
  end
end

function handle_cursor_movement(p, p_id, vs)
  if ccp.chars_selected then
    return
  end

  local new_char, is_vs_selected = p.highlighted_char, vs.has_joined and vs.temp_char
  local mv_cursor = function(i)
    new_char += i
    sfx(34)
  end

  if p.has_joined and not p.temp_char then
    if btnp(⬆️, p_id) then
      mv_cursor(new_char < 5 and 8 or -4)
    elseif btnp(⬇️, p_id) then
      mv_cursor(new_char > 8 and -8 or 4)
    elseif btnp(⬅️, p_id) then
      mv_cursor((new_char == 1 or new_char == 5 or new_char == 9) and 3 or -1)
    elseif btnp(➡️, p_id) then
      mv_cursor(new_char % 4 == 0 and -3 or 1)
    elseif btnp(🅾️, p_id) or btnp(❎, p_id) then
      p.temp_char = chars[new_char]

      if is_vs_selected or not vs.has_joined then
        sfx(35)
        ccp.chars_selected = true
        p.char = p.temp_char

        if is_vs_selected then
          vs.char = vs.temp_char
        end
      end
    end

    p.highlighted_char = new_char
  else
    if btnp(🅾️, p_id) or btnp(❎, p_id) then
      init_player(p)
    end
  end
end