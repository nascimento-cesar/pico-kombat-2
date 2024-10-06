function _draw()
  cls(2)
  draw_debug()
  draw_player()
end

function draw_player()
  pal(5, 0)
  pal(13, 5)
  set_player_sprite()
  spr(player.rendering.current_sprite, player.rendering.x, player.rendering.y)
  pal()
end

function set_player_sprite()
  local sprite_index
  sprite_index = flr(player.rendering.frames_counter / player.action.current.frames_per_sprite) + 1
  player.rendering.current_sprite = player.action.current.sprites[sprite_index]
end

function draw_debug()
  local i = 1
  for k, v in pairs(debug) do
    print(k .. ": " .. v, 0, (i - 1) * 10)
    i += 1
  end
end