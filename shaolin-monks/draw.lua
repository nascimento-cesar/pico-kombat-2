function _draw()
  cls(1)
  draw_debug()
  draw_player(p1)
  draw_player(p2)
end

function draw_player(p)
  local flip_x = false
  local flip_y = false
  local id
  local index
  local sprite
  local sprites = p.current_action.sprites

  if is_action_held(p) then
    index = #sprites
  else
    index = flr(p.frames_counter / p.current_action.frames_per_sprite) + 1

    if is_action_released(p) then
      index = #sprites - index + 1
    end
  end

  sprite = sprites[index]

  if type(sprite) == "table" then
    id = sprite[1]
    flip_x = sprite[2]
    flip_y = sprite[3]
  else
    id = sprite
  end

  if p.facing == directions.backward then
    flip_x = not flip_x
  end

  pal(5, 0)
  pal(13, 5)
  spr(id + p.character.sprite_offset, p.x, p.y, 1, 1, flip_x, flip_y)
  print(p.hp, p.x, p.y - 8)
  pal()

  if p.projectile then
    draw_projectile(p)
  end

  draw_particles(p)
end

function draw_projectile(p)
  local flip_x = false
  local index
  local sprites = p.character.projectile.sprites

  index = flr(p.projectile.frames_counter / p.character.projectile.frames_per_sprite) + 1

  if index > #sprites then
    index = 1
    p.projectile.frames_counter = 0
  end

  if p.facing == directions.backward then
    flip_x = not flip_x
  end

  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, flip_x)
end

function draw_particles(p)
  for particle_set in all(p.particle_sets) do
    for particle in all(particle_set.particles) do
      particle.x += particle.speed_x
      particle.y += particle.speed_y

      pset(particle.x, particle.y, particle_set.color)

      particle.current_lifespan += 1

      if particle.current_lifespan > particle.max_lifespan then
        del(particle_set.particles, particle)
      end
    end

    if #particle_set.particles == 0 then
      del(p.particle_sets, particle_set)
    end
  end
end

function draw_debug()
  local i = 1

  for k, v in pairs(debug) do
    local s = ""

    if type(v) == "table" then
      for v2 in all(v) do
        if s ~= "" then
          s = s and s .. ", " .. v2 or v2
        else
          s = v2
        end
      end
    else
      s = v
    end

    print(k .. ": " .. s, 0, (i - 1) * 10, 7)

    i += 1
  end
end