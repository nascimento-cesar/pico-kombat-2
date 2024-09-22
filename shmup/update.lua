function _update()
  if is_game_mode() then
    update_game()
  elseif is_start_mode() then
    update_start()
  elseif is_game_over_mode() then
    update_game_over()
  end

  if btnp(🅾️) then
    lives -= 1
  end
end

function update_game()
  handle_ship_controls()
  handle_firing()
  handle_map_boundaries()
  animate_starfield()
  handle_game_over()
end

function update_start()
  if any_key_pressed() then
    start_game()
  end
end

function update_game_over()
  if any_key_pressed() then
    start_game()
  end
end

function handle_ship_controls()
  ship.sprite = sprites.ship.default

  if btn(⬅️) then
    ship.x -= ship.speed
    ship.sprite = sprites.ship.left
  end

  if btn(➡️) then
    ship.x += ship.speed
    ship.sprite = sprites.ship.right
  end

  if btn(⬆️) then
    ship.y -= ship.speed
  end

  if btn(⬇️) then
    ship.y += ship.speed
  end
end

function handle_firing()
  if btnp(❎) then
    sfx(0)
    bullet.muzzle_r = muzzle_r
    bullet.x, bullet.y = get_ship_front_axes()
  end

  if bullet.muzzle_r >= 0 then
    bullet.muzzle_r -= 1
  end

  bullet.y -= bullet.speed
end

function handle_map_boundaries()
  if ship.x + 8 > map_w then
    ship.x = map_w - tile_w
  end

  if ship.x < 0 then
    ship.x = 0
  end

  if ship.y + 8 > map_h then
    ship.y = map_h - tile_h
  end

  if ship.y < 0 then
    ship.y = 0
  end

  if bullet.y > map_w then
  end
end

function animate_starfield()
  for i = 1, stars.count do
    local current_star_y = stars.y[i]

    current_star_y += stars.speed[i]

    if current_star_y > map_h then
      current_star_y -= map_h
      stars.x[i] = flr(rnd(128))
    end

    stars.y[i] = current_star_y
  end
end

function handle_game_over()
  if lives == 0 then
    current_mode = modes.over
  end
end