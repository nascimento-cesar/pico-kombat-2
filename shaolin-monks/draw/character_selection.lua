function draw_character_selection()
  cls()
  local w = 20
  local col, row, h, offset = 1, 1, 20, (w - 8) / 2

  for i = 1, 12 do
    local c, x, y = characters[i], (128 - 4 * w) / 2 + w * (col - 1), (128 - 3 * h) / 2 + h * (row - 1)

    rectfill(x, y, x + w - 1, y + h - 1, c.bg_color or 1)
    shift_pal(c.body_pal_map)
    spr(0, x + offset, y + offset)
    pal()
    shift_pal(c.head_pal_map)
    spr(c.head_sprites[1], x + offset, y + offset)
    pal()

    foreach_player(function(p)
      if i == p.highlighted_char and p.has_joined then
        rect(x, y, x + w - 1, y + h - 1, get_blinking_color(6, 7))
      end
    end)

    if col % 4 == 0 then
      col = 1
      row += 1
    else
      col += 1
    end
  end
end