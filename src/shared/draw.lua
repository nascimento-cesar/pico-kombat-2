function shift_pal(palette)
  local palette = sub(palette or "p", 2)

  for i = 1, #palette, 2 do
    pal(
      tonum("0x0" .. sub(palette, i, i)),
      tonum("0x0" .. sub(palette, i + 1, i + 1))
    )
  end
end

function draw_blinking_text(s)
  print(s, get_hcenter(s), get_vcenter(), get_blinking_color())
end

function get_blinking_color(c1, c2, s)
  c1, c2, s = c1 or 7, c2 or 8, s or 4

  return sin(time() * s) > 0 and c1 or c2
end

function get_hcenter(s)
  return 64 - (s and #tostr(s) or 0) * 2
end

function get_vcenter()
  return 61
end