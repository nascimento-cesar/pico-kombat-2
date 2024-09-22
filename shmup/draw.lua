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
  draw_debug()
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
  print(instructions, hcenter(instructions), tile_h * 4, current_blink_color)
  current_blink_color += .2

  if current_blink_color > 7 then
    current_blink_color = 5
  end
end

function draw_ship()
  spr(ship.sprite, ship.x, ship.y)

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

    spr(sprites.enemy[flr(enemy.sprite_i)], enemy.x, enemy.y)
  end
end

function draw_debug()
  print(ship.x, 0, 16, 7)
  print(ship.y, 0, 24, 7)
  print(#bullets, 0, 32, 7)
  print(#enemies, 0, 40, 7)
end