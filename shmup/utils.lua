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

function start_game()
  _init()
  current_mode = modes.wave
end

function random_axis()
  return flr(rnd(128))
end

function objects_collided(collisor, collided)
  local x1 = collisor.x
  local x2 = collisor.x + tile_w
  local y1 = collisor.y
  local y2 = collisor.y + tile_h

  local l_col = x1 < collided.x + tile_w and x2 > collided.x
  local r_col = x2 > collided.x and x1 < collided.x + tile_w
  local u_col = y1 < collided.y + tile_h and y2 > collided.y
  local d_col = y2 > collided.y and y1 < collided.y + tile_h

  return (r_col or l_col) and (u_col or d_col)
end