function _draw()
  cls(2)
  draw_debug()
  draw_players()
end

function draw_players()
  for p in all(players) do
    pal(5, 0)
    pal(13, 5)
    set_player_sprite(p)
    spr(p.current_sprite, p.x, p.y)
    pal()
  end
end

function set_player_sprite(p)
  local sprite_index

  if is_action_held(p) then
    sprite_index = #p.current_action.sprites
  else
    sprite_index = flr(p.frames_counter / p.current_action.frames_per_sprite) + 1

    if is_action_released(p) then
      sprite_index = #p.current_action.sprites - sprite_index + 1
    end
  end

  p.current_sprite = p.current_action.sprites[sprite_index] + p.character
end

function draw_debug()
  local i = 1
  for k, v in pairs(debug) do
    print(k .. ": " .. v, 0, (i - 1) * 10)
    i += 1
  end
end