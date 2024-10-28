function _draw()
  if game.current_screen == screens.character_selection then
    draw_character_selection()
  elseif game.current_screen == screens.gameplay then
    draw_gameplay()
  elseif game.current_screen == screens.start then
    draw_start()
  end
end

function draw_character_selection()
  cls(0)

  local col = 1
  local row = 1
  local h = 20
  local w = 20
  local offset = (w - 8) / 2

  for i = 1, 12 do
    local c = characters[characters.order[tostr(i)]]
    local x = (128 - 4 * w) / 2 + w * (col - 1)
    local y = (128 - 3 * h) / 2 + h * (row - 1)

    rectfill(x, y, x + w, y + h, c.background_color or 1)
    change_pallete(c.pallete_map)
    spr(0, x + offset, y + offset)
    pal()
    change_pallete(c.head_pallete_map or c.pallete_map)
    spr(c.head_sprites[1], x + offset, y + offset)
    pal()
    spr(128, 0, 0)

    if i == p1.highlighted_char or i == p2.highlighted_char then
      rect(x, y, x + w - 1, y + h - 1, get_blinking_color(6, 7))
    end

    if col % 4 == 0 then
      col = 1
      row += 1
    else
      col += 1
    end
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
  local head_x_adjustment = 0
  local head_y_adjustment = 0
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
  end

  if p.facing == directions.backward then
    flip_body_x = not flip_body_x
    flip_head_x = not flip_head_x
  end

  draw_head(p, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
  draw_body(p, body_id, flip_body_x, flip_body_y)

  if p.projectile then
    draw_projectile(p)
  end

  draw_particles(p)
end

function draw_head(p, id, x_adjustment, y_adjustment, flip_x, flip_y)
  change_pallete(p.character.head_pallete_map or p.character.pallete_map)
  spr(p.character.head_sprites[id], p.x + x_adjustment * p.facing, p.y + y_adjustment, 1, 1, flip_x, flip_y)
  pal()
end

function draw_body(p, id, flip_x, flip_y)
  change_pallete(p.character.pallete_map)
  spr(id, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function change_pallete(pallete)
  for color in all(pallete) do
    pal(color[1], color[2])
  end
end

function draw_projectile(p)
  local flip_x = false
  local index
  local projectile = p.character.projectile
  local sprites = projectile.sprites

  index = flr(p.projectile.frames_counter / projectile.frames_per_sprite) + 1

  if index > #sprites then
    index = 1
    p.projectile.frames_counter = 0
  end

  if p.facing == directions.backward then
    flip_x = not flip_x
  end

  for color in all(projectile.pallete_map) do
    pal(color[1], color[2])
  end

  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, flip_x)
  pal()
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
  print(s, x, y, get_blinking_color())
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