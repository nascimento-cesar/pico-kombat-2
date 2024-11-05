function update_character_selection()
  foreach_player(handle_cursor_movement)
end

function handle_cursor_movement(p, p_id, vs)
  local new_char = p.highlighted_char

  if is_playing(p) then
    if btnp(⬆️, p_id) then
      new_char += new_char < 5 and 8 or -4
    elseif btnp(⬇️, p_id) then
      new_char += new_char > 8 and -8 or 4
    elseif btnp(⬅️, p_id) then
      new_char += (new_char == 1 or new_char == 5 or new_char == 9) and 3 or -1
    elseif btnp(➡️, p_id) then
      new_char += new_char % 4 == 0 and -3 or 1
    elseif btnp(🅾️, p_id) or btnp(❎, p_id) then
      p.character = characters[new_char]

      if not is_playing(vs) or is_playing(vs) and vs.character then
        game.current_screen = "next_combat"
      end
    end

    p.highlighted_char = new_char
  else
    if btnp(🅾️, p_id) or btnp(❎, p_id) then
      init_player(p)
    end
  end
end