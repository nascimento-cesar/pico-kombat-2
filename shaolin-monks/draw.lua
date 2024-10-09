function _draw()
  cls(1)
  draw_debug()

  for p in all(players) do
    draw_player(p)

    if p.projectile then
      draw_projectile(p)
    end
  end
end

function draw_player(p)
  local flip_x = false
  local flip_y = false
  local id
  local index
  local sprite
  local sprites = p.current_action.sprites

  if is_action_held(p) then
    index = #sprites
  else
    index = flr(p.frames_counter / p.current_action.frames_per_sprite) + 1

    if is_action_released(p) then
      index = #sprites - index + 1
    end
  end

  sprite = sprites[index]

  if type(sprite) == "table" then
    id = sprite[1]
    flip_x = sprite[2]
    flip_y = sprite[3]
  else
    id = sprite
  end

  pal(5, 0)
  pal(13, 5)
  spr(id + p.character.sprite_offset, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function draw_projectile(p)
  local index
  local sprites = p.character.projectile.sprites

  index = flr(p.projectile.frames_counter / p.character.projectile.frames_per_sprite) + 1

  if index > #sprites then
    index = 1
    p.projectile.frames_counter = 0
  end

  spr(sprites[index], p.projectile.x, p.projectile.y)
end

function draw_debug()
  local i = 1

  for k, v in pairs(debug) do
    local s = ""

    if type(v) == "table" then
      for v2 in all(v) do
        if s ~= "" then
          s = s and s .. ", " .. v2 or v2
        else
          s = v2
        end
      end
    else
      s = v
    end

    print(k .. ": " .. s, 0, (i - 1) * 10)

    i += 1
  end
end