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
  handle_enemies()
  handle_map_boundaries()
  animate_starfield()
  handle_game_over()
  handle_enemy_collision()
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
    if btn(⬆️) then
      ship.y -= ship.speed / 2
    elseif btn(⬇️) then
      ship.y += ship.speed / 2
    end

    ship.x -= ship.speed

    ship.sprite = sprites.ship.left
  elseif btn(➡️) then
    if btn(⬆️) then
      ship.y -= ship.speed / 2
    elseif btn(⬇️) then
      ship.y += ship.speed / 2
    end

    ship.x += ship.speed

    ship.sprite = sprites.ship.right
  elseif btn(⬆️) then
    ship.y -= ship.speed
  elseif btn(⬇️) then
    ship.y += ship.speed
  end
end

function handle_firing()
  if btn(❎) then
    if bullet_cooldown <= 0 then
      sfx(0)
      local bullet_x, bullet_y = get_ship_front_axes()
      local new_bullet = {
        x = bullet_x,
        y = bullet_y,
        muzzle_r = muzzle_r
      }
      add(bullets, new_bullet)
      bullet_cooldown = bullet_ratio
    end

    bullet_cooldown -= 1
  end

  for bullet in all(bullets) do
    if bullet.muzzle_r >= 0 then
      bullet.muzzle_r -= 1
    end

    for enemy in all(enemies) do
      local hit = objects_collided(bullet, enemy)

      if hit then
        sfx(1)
        del(enemies, enemy)
        score += enemy.points
        set_enemies()
      end
    end

    bullet.y -= bullet_speed
  end
end

function handle_enemies()
  local speed = 1
  for enemy in all(enemies) do
    enemy.y += speed
  end
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

  for i = #bullets, 1, -1 do
    local bullet = bullets[i]

    if bullet.y < 0 then
      deli(bullets, i)
    end
  end

  for i = #enemies, 1, -1 do
    local enemy = enemies[i]

    if enemy.y > map_h then
      deli(enemies, i)
      set_enemies()
    end
  end
end

function animate_starfield()
  for star in all(stars) do
    local current_star_y = star.y

    current_star_y += star.speed

    if current_star_y > map_h then
      current_star_y -= map_h
      star.x = random_axis()
    end

    star.y = current_star_y
  end
end

function handle_game_over()
  if lives == 0 then
    current_mode = modes.over
  end
end

function handle_enemy_collision()
  for enemy in all(enemies) do
    local ship_collided = objects_collided(ship, enemy)

    if ship_collided and invincibility_frames <= 0 then
      lives -= 1
      invincibility_frames = 30
    end
  end

  invincibility_frames -= 1
end