function _draw()
  cls(1)
  draw_debug()
  draw_player(p1)
  draw_player(p2)
end

function draw_player(player)
  local flip_x = false
  local flip_y = false
  local id
  local index
  local sprite
  local sprites = player.current_action.sprites

  if is_action_held(player) then
    index = #sprites
  else
    index = flr(player.frames_counter / player.current_action.frames_per_sprite) + 1

    if is_action_released(player) then
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

  if player.facing == directions.backward then
    flip_x = not flip_x
  end

  pal(5, 0)
  pal(13, 5)
  spr(id + player.character.sprite_offset, player.x, player.y, 1, 1, flip_x, flip_y)
  print(player.hp, player.x, player.y - 8)
  pal()

  if player.projectile then
    draw_projectile(player)
  end
end

function draw_projectile(player)
  local flip_x = false
  local index
  local sprites = player.character.projectile.sprites

  index = flr(player.projectile.frames_counter / player.character.projectile.frames_per_sprite) + 1

  if index > #sprites then
    index = 1
    player.projectile.frames_counter = 0
  end

  if player.facing == directions.backward then
    flip_x = not flip_x
  end

  spr(sprites[index], player.projectile.x, player.projectile.y, 1, 1, flip_x)
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