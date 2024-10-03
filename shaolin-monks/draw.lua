function _draw()
  cls(3)

  print(player.x, 0, 0)

  -- for i = 1, #actions_stack do
  --   print(actions_stack[i], i * 10, 0)
  -- end

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