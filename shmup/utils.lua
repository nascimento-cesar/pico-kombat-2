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

function start_game()
  _init()
  current_mode = modes.game
end

function random_axis()
  return flr(rnd(128))
end