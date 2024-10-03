function _draw()
  cls(3)

  draw_debug()
  draw_player()
end

function draw_player()
  pal(5, 0)
  pal(13, 5)
  set_player_sprite()
  spr(player.current_sprite, player.x, player.y)
  pal()
end

function set_player_sprite()
  player.current_sprite = player.current_action.s[flr(player.frames_counter / player.current_action.f) + 1]
end

function draw_debug()
  local i = 1
  for k, v in pairs(debug) do
    print(k .. ": " .. v, 0, (i - 1) * 10)
    i += 1
  end
end