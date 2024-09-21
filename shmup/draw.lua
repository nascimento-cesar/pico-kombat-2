function _draw()
  cls(0)
  draw_starfield()
  draw_score()
  draw_lives()
  draw_ship()
  draw_bullet()
  -- draw_debug()
end

function draw_ship()
  spr(ship.sprite, ship.x, ship.y)

  if ship.thruster_sprite_i >= #sprites.thruster then
    ship.thruster_sprite_i = 1
  else
    local thruster_speed = .5
    ship.thruster_sprite_i += thruster_speed
  end

  spr(sprites.thruster[flr(ship.thruster_sprite_i)], ship.x, ship.y + 8)
end

function draw_bullet()
  spr(sprites.bullet.default, bullet.x, bullet.y)

  if bullet.muzzle_r > 0 then
    draw_muzzle()
  end
end

function draw_muzzle()
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
  for i = 1, stars.count do
    local star_color = 7

    if stars.speed[i] < 1 then
      star_color = 1
    elseif stars.speed[i] < 1.5 then
      star_color = 13
    end

    pset(stars.x[i], stars.y[i], star_color)
  end
end

function draw_debug()
  print(ship.x, 0, 0, 7)
  print(ship.y, 0, 8, 7)
end