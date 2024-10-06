function _draw()
  cls(2)
  draw_players()
  draw_debug()
end

function draw_players()
  for p in all(players) do
    pal(5, 0)
    pal(13, 5)
    set_player_sprite(p)
    spr(p.rendering.current_sprite, p.rendering.x, p.rendering.y)
    pal()
  end
end

function set_player_sprite(p)
  local sprite_index

  if p.current_action.is_held and not p.current_action.action.is_movement then
    sprite_index = #p.current_action.action.sprites
  else
    sprite_index = flr(p.rendering.frames_counter / p.current_action.action.frames_per_sprite) + 1
  end

  p.rendering.current_sprite = p.current_action.action.sprites[sprite_index] + p.character
end

function draw_debug()
  local i = 1
  for k, v in pairs(debug) do
    print(k .. ": " .. v, 0, (i - 1) * 10)
    i += 1
  end
end