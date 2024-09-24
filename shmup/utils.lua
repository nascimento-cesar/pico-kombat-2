function hcenter(s)
  return 64 - #s * 2
end

function vcenter(s)
  return 61
end

function get_ship_front_axes()
  return ship.x, ship.y - tile_h / 2
end

function is_game_mode()
  return current_mode == modes.game
end

function is_start_mode()
  return current_mode == modes.start
end

function is_game_over_mode()
  return current_mode == modes.over
end

function is_wave_mode()
  return current_mode == modes.wave
end

function is_victory_mode()
  return current_mode == modes.victory
end

function random_axis()
  return flr(rnd(128))
end

function objects_collided(c1, c2, c1_w, c1_h, c2_w, c2_h)
  local c1_w = c1_w or tile_w
  local c1_h = c1_h or tile_h
  local c2_w = c2_w or tile_w
  local c2_h = c2_h or tile_h

  local x1 = c1.x
  local x2 = c1.x + c1_w
  local y1 = c1.y
  local y2 = c1.y + c1_h

  local l_col = x1 < c2.x + c2_w and x2 > c2.x
  local r_col = x2 > c2.x and x1 < c2.x + c2_w
  local u_col = y1 < c2.y + c2_h and y2 > c2.y
  local d_col = y2 > c2.y and y1 < c2.y + c2_h

  return (r_col or l_col) and (u_col or d_col)
end