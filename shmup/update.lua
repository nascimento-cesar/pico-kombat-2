function _update()
  if is_start_mode() then
    update_start()
  elseif is_game_mode() then
    update_game()
  elseif is_wave_mode() then
    update_wave()
  elseif is_game_over_mode() then
    update_game_over()
  elseif is_victory_mode() then
    update_victory()
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
  handle_wave_end()
end

function update_start()
  if handle_start_button_pressed() then
    start_game()
  end
end

function update_wave()
  update_game()
  wave_time += 1

  if wave_time > default_wave_time then
    current_mode = modes.game
  end
end

function update_game_over()
  if handle_start_button_pressed() then
    start_game()
  end
end

function update_victory()
  if handle_start_button_pressed() then
    current_mode = modes.start
  end
end

function start_game()
  _init()
  start_next_wave()
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

  if btnp(🅾️) then
    explode_ship()
  end
end

function handle_firing()
  if lives <= 0 then
    return
  end

  if btn(❎) then
    if bullet_cooldown <= 0 then
      sfx(sounds.fire)
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
      local sprite = sprites.enemies[enemy.type]
      local hit = objects_collided(bullet, enemy, 1, 1, sprite.size, sprite.size)

      if hit then
        del(bullets, bullet)
        enemy.hp -= 1
        enemy.flashing_speed = 2

        if enemy.hp > 0 then
          create_shockwave(bullet)
          sfx(sounds.hit)
        else
          sfx(sounds.hit_kill)
          -- create_explosion(enemy)
          create_shockwave(bullet, true)
          create_particle(enemy, particle_palletes.enemy)
          del(enemies, enemy)
          score += enemy.points
        end
      end
    end

    bullet.y -= bullet_speed
  end
end

function start_next_wave()
  current_wave += 1

  if current_wave <= max_waves then
    current_mode = modes.wave
    wave_time = 0

    if current_wave == 1 then
      add_enemy(enemy_types.green_alien)
    elseif current_wave == 2 then
      add_enemy(enemy_types.flaming_guy)
    elseif current_wave == 3 then
      add_enemy(enemy_types.spinning_ship)
    else
      add_enemy(enemy_types.boss)
    end
  else
    current_mode = modes.victory
  end
end

function create_shockwave(object, bigger)
  local ratio = bigger and 2.5 or 1

  add(
    shockwaves, {
      x = object.x,
      y = object.y,
      radius = 2.5 * ratio,
      max_radius = 10 * ratio,
      color = bigger and 7 or 9
    }
  )
end

-- function create_explosion(enemy)
--   add(
--     explosions, {
--       sprite_i = 1,
--       x = enemy.x,
--       y = enemy.y
--     }
--   )
-- end

function create_particle(object, pallete)
  local particles_count = 60

  for i = 1, particles_count do
    local is_spark = rnd() > 0.5 and true or false

    add(
      particles, {
        color = pallete[1],
        size = 1 + rnd(4),
        lifespan = rnd(5),
        max_lifespan = 10 + rnd(10),
        x = object.x,
        y = object.y,
        pallete = pallete,
        speed_x = is_spark and (rnd() - 0.5) * 12 or rnd() * 4 - 2,
        speed_y = is_spark and (rnd() - 0.5) * 12 or rnd() * 4 - 2,
        spark = is_spark
      }
    )
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
  if lives <= 0 then
    if game_over_delay <= 0 then
      current_mode = modes.over
      game_over_delay = default_game_over_delay
    else
      game_over_delay -= 1
    end
  end
end

function handle_enemy_collision()
  for enemy in all(enemies) do
    local sprite = sprites.enemies[enemy.type]
    local ship_collided = objects_collided(ship, enemy, 1, 1, sprite.size, sprite.size)

    if ship_collided and invincibility_frames <= 0 then
      explode_ship()
    end
  end

  invincibility_frames -= 1
end

function explode_ship()
  sfx(sounds.damage)
  create_particle(ship, particle_palletes.ship)
  lives -= 1
  invincibility_frames = 30
  ship.x = initial_x
  ship.y = initial_y
end

function handle_start_button_pressed()
  if btn(❎) == false and btn(🅾️) == false then
    start_button_released = true
  end

  if start_button_released then
    if btnp(❎) or btnp(🅾️) then
      start_button_released = false
      return true
    end
  end

  return false
end

function handle_wave_end()
  if #enemies == 0 then
    start_next_wave()
  end
end

function add_enemy(type)
  local new_enemy = {
    type = type or enemy_types.green_alien,
    sprite_i = 1,
    x = flr(rnd(128 - tile_w)),
    y = -tile_h,
    points = 100,
    flashing_speed = 0,
    hp = 2
  }
  add(enemies, new_enemy)
end