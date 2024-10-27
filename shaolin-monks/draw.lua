function _draw()
  if game.current_screen == screens.gameplay then
    draw_gameplay()
  elseif game.current_screen == screens.start then
    draw_start()
  end
end

function draw_gameplay()
  cls(2)
  draw_debug()
  draw_player(p1)
  draw_player(p2)
end

function draw_start()
  cls(0)
  local text = "press ❎ to start"
  draw_blinking_text(text, get_hcenter(text), get_vcenter())
end

function draw_player(p)
  local flip_body_x = false
  local flip_body_y = false
  local flip_head_x = false
  local flip_head_y = false
  local body_id
  local head_id
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
    body_id = sprite[1]
    head_id = sprite[2]
    head_x_adjustment = sprite[3] or 0
    head_y_adjustment = sprite[4] or 0
    flip_body_x = sprite[5]
    flip_body_y = sprite[6]
    flip_head_x = sprite[7]
    flip_head_y = sprite[8]
  else
    body_id = sprite
    head_id = 1
    head_x_adjustment = 0
    head_y_adjustment = 0
  end

  if p.facing == directions.backward then
    flip_body_x = not flip_body_x
    flip_head_x = not flip_head_x
  end

  for color in all(p.character.pallete_map) do
    if color[2] == -1 then
      palt(color[1], true)
    else
      pal(color[1], color[2])
    end
  end

  spr(body_id, p.x, p.y, 1, 1, flip_body_x, flip_body_y)
  spr(p.character.head_sprites[head_id], p.x + head_x_adjustment * p.facing, p.y + head_y_adjustment, 1, 1, flip_head_x, flip_head_y)
  -- print(p.hp, p.x, p.y - 8, 7)
  pal()
  palt()

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

function draw_blinking_text(s, x, y)
  local color = sin(time() * 4) > 0 and 7 or 8
  print(s, x, y, color)
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