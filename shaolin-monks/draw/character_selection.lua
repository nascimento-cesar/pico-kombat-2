function draw_character_selection()
  cls(0)
  draw_debug()

  local col = 1
  local row = 1
  local h = 20
  local w = 20
  local offset = (w - 8) / 2

  for i = 1, 12 do
    local c = characters[i]
    local x = (128 - 4 * w) / 2 + w * (col - 1)
    local y = (128 - 3 * h) / 2 + h * (row - 1)

    rectfill(x, y, x + w - 1, y + h - 1, c.background_color or 1)
    change_pallete(c.pallete_map)
    spr(0, x + offset, y + offset)
    pal()
    change_pallete(c.head_pallete_map or c.pallete_map)
    spr(c.head_sprites[1], x + offset, y + offset)
    pal()

    for p in all({ p1, p2 }) do
      if i == p.highlighted_char and is_playing(p) then
        rect(x, y, x + w - 1, y + h - 1, get_blinking_color(6, 7))
      end
    end

    if col % 4 == 0 then
      col = 1
      row += 1
    else
      col += 1
    end
  end
end