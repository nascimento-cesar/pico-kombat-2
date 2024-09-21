function _init()
  parts = {}
end

function _update()
  if btnp(❎) then
    for i = 1, 50 do
      add(
        parts, {
          x = 63,
          y = 63,
          sx = rnd(2) - 1,
          sy = rnd(2) - 1,
          c = rnd(16),
          r = rnd(4)
        }
      )
    end
  end

  for p in all(parts) do
    p.x += p.sx
    p.y += p.sy

    if p.x > 128 or p.x < 0 then
      del(parts, p)
    end
  end
end

function _draw()
  cls()
  for p in all(parts) do
    circfill(p.x, p.y, p.r, p.c)
  end
end