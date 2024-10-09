function _draw()
  cls(2)
  draw_debug()
  draw_players()
end

function draw_players()
  for p in all(players) do
    draw_player(p)
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
  spr(id + p.character, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function draw_debug()
  local i = 1
  for k, v in pairs(debug) do
    print(k .. ": " .. v, 0, (i - 1) * 10)
    i += 1
  end
end