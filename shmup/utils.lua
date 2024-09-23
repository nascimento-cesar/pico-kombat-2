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

function objects_collided(c1, c2, c1x_t, c1y_t, c2x_t, c2y_t)
  local c1x_t = c1x_t or 1
  local c1y_t = c1y_t or 1
  local c2x_t = c2x_t or 1
  local c2y_t = c2y_t or 1

  local x1 = c1.x
  local x2 = c1.x + tile_w * c1x_t
  local y1 = c1.y
  local y2 = c1.y + tile_h * c1y_t

  local l_col = x1 < c2.x + tile_w * c2x_t and x2 > c2.x
  local r_col = x2 > c2.x and x1 < c2.x + tile_w * c2x_t
  local u_col = y1 < c2.y + tile_h * c2y_t and y2 > c2.y
  local d_col = y2 > c2.y and y1 < c2.y + tile_h * c2y_t

  return (r_col or l_col) and (u_col or d_col)
end