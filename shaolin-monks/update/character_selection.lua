function update_character_selection()
  for p in all({ p1, p2 }) do
    local new_char = p.highlighted_char

    if is_playing(p) then
      if btnp(⬆️, p.id) then
        if new_char < 5 then
          new_char += 8
        else
          new_char -= 4
        end
      elseif btnp(⬇️, p.id) then
        if new_char > 8 then
          new_char -= 8
        else
          new_char += 4
        end
      elseif btnp(⬅️, p.id) then
        if new_char == 1 or new_char == 5 or new_char == 9 then
          new_char += 3
        else
          new_char -= 1
        end
      elseif btnp(➡️, p.id) then
        if new_char % 4 == 0 then
          new_char -= 3
        else
          new_char += 1
        end
      elseif btnp(🅾️, p.id) or btnp(❎, p.id) then
        p.character = characters[new_char]
        local vs = get_vs(p)

        if not is_playing(vs) or is_playing(vs) and vs.character then
          game.current_screen = screens.next_combat
        end
      end

      p.highlighted_char = new_char
    else
      if btnp(🅾️, p.id) or btnp(❎, p.id) then
        init_player(p)
      end
    end
  end
end