function _draw()
  if is_game_mode() then
    draw_game()
  elseif is_start_mode() then
    draw_start()
  elseif is_game_over_mode() then
    draw_game_over()
  end
end

function draw_game()
  cls(0)
  draw_starfield()
  draw_score()
  draw_lives()
  draw_ship()
  draw_bullet()
  draw_enemies()
  draw_shockwaves()
  -- draw_explosions()
  draw_particles()
  -- draw_debug()
end

function draw_start()
  cls(1)
  print(game_title, hcenter(game_title), tile_h * 2, 10)
  draw_init_instructions()
end

function draw_game_over()
  cls(8)
  local message = "game over"
  print(message, hcenter(message), tile_h * 2, 10)
  draw_init_instructions()
end

function draw_init_instructions()
  local instructions = "press any key to start"
  print(instructions, hcenter(instructions), tile_h * 4, text_blink_color)
  text_blink_color += .2

  if text_blink_color > 7 then
    text_blink_color = 5
  end
end

function draw_ship()
  if invincibility_frames > 0 then
    if sin(invincibility_frames / 5) < 0 then
      spr(ship.sprite, ship.x, ship.y)
    end
  else
    spr(ship.sprite, ship.x, ship.y)
    draw_thruster()
  end
end

function draw_thruster()
  if ship.thruster_sprite_i >= #sprites.thruster then
    ship.thruster_sprite_i = 1
  else
    local animation_speed = .5
    ship.thruster_sprite_i += animation_speed
  end

  spr(sprites.thruster[flr(ship.thruster_sprite_i)], ship.x, ship.y + 8)
end

function draw_bullet()
  for bullet in all(bullets) do
    spr(sprites.bullet.default, bullet.x, bullet.y)

    if bullet.muzzle_r > 0 then
      draw_muzzle(bullet)
    end
  end
end

function draw_muzzle(bullet)
  local muzzle_x, muzzle_y = get_ship_front_axes()
  circfill(muzzle_x + tile_w / 2, muzzle_y, bullet.muzzle_r, 7)
end

function draw_score()
  local s = "score: " .. score
  print(s, hcenter(s), 0, 10)
end

function draw_lives()
  for i = 1, max_lives do
    local s = i <= lives and sprites.lives.default or sprites.lives.empty
    spr(s, (i - 1) * tile_w * 1.25, 0)
  end
end

function draw_starfield()
  for star in all(stars) do
    local star_color = 7

    if star.speed < 1 then
      star_color = 1
    elseif star.speed < 1.5 then
      star_color = 13
    end

    pset(star.x, star.y, star_color)
  end
end

function draw_enemies()
  for enemy in all(enemies) do
    if enemy.sprite_i >= #sprites.enemy then
      enemy.sprite_i = 1
    else
      local animation_speed = .1
      enemy.sprite_i += animation_speed
    end

    if enemy.flashing_speed > 0 then
      enemy.flashing_speed -= 1

      for i = 1, 15 do
        pal(i, 7)
      end
    end

    spr(sprites.enemy[flr(enemy.sprite_i)], enemy.x, enemy.y)
    pal()
  end
end

function draw_particles()
  for particle in all(particles) do
    particle.x += particle.speed_x
    particle.y += particle.speed_y
    particle.speed_x *= 0.9
    particle.speed_y *= 0.9
    particle.lifespan += 1

    if particle.spark then
      pset(particle.x, particle.y, 7)
    else
      local percentage = particle.max_lifespan / 100

      if particle.lifespan > percentage * 90 then
        particle.color = particle.pallete[4]
      elseif particle.lifespan > percentage * 70 then
        particle.color = particle.pallete[3]
      elseif particle.lifespan > percentage * 40 then
        particle.color = particle.pallete[2]
      end

      circfill(particle.x, particle.y, particle.size, particle.color)
    end

    if particle.lifespan > particle.max_lifespan then
      particle.size -= 0.5

      if particle.size <= 0 then
        del(particles, particle)
      end
    end
  end
end

function draw_shockwaves()
  for wave in all(shockwaves) do
    circ(wave.x, wave.y, wave.radius, wave.color)
    wave.radius += 1.5

    if wave.radius > wave.max_radius then
      del(shockwaves, wave)
    end
  end
end

-- function draw_explosions()
--   for explosion in all(explosions) do
--     spr(sprites.explosion[flr(explosion.sprite_i)], explosion.x - tile_w / 2, explosion.y - tile_h / 2, 2, 2)
--     local animation_speed = .5
--     explosion.sprite_i += animation_speed

--     if explosion.sprite_i > #sprites.explosion + animation_speed then
--       del(explosions, explosion)
--     end
--   end
-- end

function draw_debug()
  print("s_x:" .. ship.x, 0, 16, 7)
  print("s_y:" .. ship.y, 0, 24, 7)
  print("enemies:" .. #enemies, 0, 32, 7)
end