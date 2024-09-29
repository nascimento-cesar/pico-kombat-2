function _init()
  s_v()
  g_s()
end

function _update()
  h_c()
  u_o()
end

function _draw()
  cls(3)

  d_p()
  d_b()
  d_m()
end

function d_p()
  if btn() & 15 > 0 then
    p.cs = sin(time() / 0.5) >= 0 and 1 or 2
  else
    p.cs = 0
  end

  spr(p.cs, p.x, p.y)
end

function d_b()
  for b in all(bs) do
    if b.t <= 1 then
      if sin(time() / 0.1) >= 0 then
        for i = 1, 15 do
          pal(i, 7)
        end
      end
    end

    spr(sin(time() / 0.75) >= 0 and 3 or 4, b.x, b.y)

    pal()
  end
end

function d_m()
  for r = 1, 17 do
    for c = 1, 17 do
      local s
      if r == 1 or r == 17 then s = 6 end
      if c == 1 or c == 17 or r == 1 or r == 17 or c % 2 == 1 and r % 2 == 1 then s = 6 end
      if r % 2 == 0 and c > 1 and c < 17 then s = 5 end
      if r % 2 == 1 and c % 2 == 0 and r != 1 and r != 17 then s = 5 end
      if (r == 2 or r == 16) and (c >= 2 and c <= 3 or c >= 15 and c <= 16) then s = nil end
      if (c == 2 or c == 16) and (r >= 2 and r <= 3 or r >= 15 and r <= 16) then s = nil end

      if s != nil then spr(s, (c - 1) * 7 + 4.5, (r - 1) * 7 + 4.5) end
    end
  end
end

function s_v()
  p = {
    x = 12.5,
    y = 12.5,
    mb = 1
  }
  es = {}
  bs = {}
  m = {}
end

function h_c()
  if btn(0) then
    p.x -= 1
  elseif btn(1) then
    p.x += 1
  elseif btn(2) then
    p.y -= 1
  elseif btn(3) then
    p.y += 1
  end

  if btnp(4) and #bs < p.mb then
    add(bs, { x = p.x, y = p.y + 2, t = 3 })
  end
end

function u_o()
  for b in all(bs) do
    if time() % 1 == 0 then
      b.t -= 1

      if b.t <= 0 then
        del(bs, b)
      end
    end
  end
end

function g_s()
  for i, s in ipairs({ "0111020002", "2111000002", "0111220000" }) do
    c_s("2777707cfc07fff" .. s, i - 1, 5, 5)
  end
  c_s("009080116111111", 3, 3, 5)
  c_s("900080116111111", 4, 3, 5)
  c_s("666666d6ddddd16ddddd16ddddd16ddddd16ddddd1d111111", 5, 7, 7)
  c_s("eeeeee2e222221e222221e222221e222221e2222212111111", 6, 7, 7)
end

function c_s(s, i, w, h)
  for r = 1, h do
    for c = 1, w do
      sset((i + 1 % 16 - 1) * 8 + c - 1, flr(i / 16) * 8 + r - 1, tonum("0x0" .. s[(r - 1) * w + c]))
    end
  end
end