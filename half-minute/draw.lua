function _draw()
  draw_game()
  -- draw_debug()
end

function draw_game()
  cls()

  if g.mode == enums.modes.overworld then
    draw_overworld()
  elseif g.mode == enums.modes.battle then
    g.b:draw()
  end
end

function draw_overworld()
  print("overworld", g.max_x / 2, g.max_y / 2)
  g.c:draw()
end

function draw_debug()
  print(h.level, 0, 20, 7)
  print(h.power, 0, 20, 7)
end