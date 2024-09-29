function _init()
  player = {
    x = 14,
    y = 16,
    current_sprite = "a",
    max_bombs = 1
  }

  bombs = {}

  sprites = {
    player = {
      base = "55200000777707cfc07fff01110",
      a = "250ddd020002",
      b = "252ddd000002",
      c = "250ddd220000"
    },
    bomb = {
      a = "53009080116111111",
      b = "53900080116111111"
    },
    brick = "886666666d6dddddd16dddddd16dddddd16dddddd16dddddd16dddddd1d1111111"
  }

  maze = {
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 1 },
    { 1, 0, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 0, 1 },
    { 1, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 1 },
    { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1 },
    { 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
    { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1 },
    { 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
    { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1 },
    { 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
    { 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1 },
    { 1, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
    { 1, 0, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 0, 1 },
    { 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
  }
end

function _update()
  if btnp(❎) and #bombs < player.max_bombs then
    add(bombs, { x = player.x, y = player.y + 2, timer = 3 })
  end

  if btn(⬅️) then
    player.x -= 1
  elseif btn(➡️) then
    player.x += 1
  elseif btn(⬆️) then
    player.y -= 1
  elseif btn(⬇️) then
    player.y += 1
  end

  for bomb in all(bombs) do
    if time() % 1 == 0 then
      bomb.timer -= 1

      if bomb.timer <= 0 then
        del(bombs, bomb)
      end
    end
  end
end

function _draw()
  cls(3)

  for r = 1, 15 do
    for c = 1, 15 do
      local s = maze[r][c]

      if s > 0 then
        if s == 1 then
          pal(6, 14)
          pal(13, 2)
        end

        draw_sprite(sprites.brick, (c - 1) * 8 + 4, r * 8)
        pal()
      end
    end
  end

  if btn(⬅️) or btn(⬆️) or btn(➡️) or btn(⬇️) then
    player.current_sprite = sin(time() / 0.5) >= 0 and "b" or "c"
  else
    player.current_sprite = "a"
  end

  draw_sprite(sprites.player.base, player.x, player.y)
  draw_sprite(sprites.player[player.current_sprite], player.x, player.y + 5)

  for bomb in all(bombs) do
    if bomb.timer <= 1 then
      if sin(time() / 0.1) >= 0 then
        for i = 1, 15 do
          pal(i, 7)
        end
      end
    end

    draw_sprite(sin(time() / 0.75) >= 0 and sprites.bomb.a or sprites.bomb.b, bomb.x, bomb.y)
    pal()
  end
end

function draw_sprite(code, x, y)
  for row = 1, code[1] do
    for column = 1, code[2] do
      local color = code[2 + (row - 1) * code[2] + column]

      if color != "0" then
        pset(x + column - 1, y + row - 1, tonum("0x0" .. color))
      end
    end
  end
end