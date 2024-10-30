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
  draw_debug()

  local col = 1
  local row = 1
  local h = 20
  local w = 20
  local offset = (w - 8) / 2

  for i = 1, 12 do
    local c = characters[i]
    local x = (128 - 4 * w) / 2 + w * (col - 1)
    local y = (128 - 3 * h) / 2 + h * (row - 1)

    rectfill(x, y, x + w - 1, y + h - 1, c.background_color or 1)
    change_pallete(c.pallete_map)
    spr(0, x + offset, y + offset)
    pal()
    change_pallete(c.head_pallete_map or c.pallete_map)
    spr(c.head_sprites[1], x + offset, y + offset)
    pal()

    for p in all({ p1, p2 }) do
      if i == p.highlighted_char and is_playing(p) then
        rect(x, y, x + w - 1, y + h - 1, get_blinking_color(6, 7))
      end
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
  cls(1)
  draw_debug()
  draw_stage()

  if is_round_finishing_move() then
    draw_finish_him_her()
  elseif is_round_finished() then
    draw_round_result()
  elseif is_round_beginning() then
    draw_round_start()
  elseif player_has_joined() then
    draw_new_player()
  end

  draw_round_timer()
  draw_hp()
  draw_player(p1)
  draw_player(p2)
end

function draw_start()
  cls(0)
  local text = "press ❎ to start"
  draw_blinking_text(text, get_hcenter(text), get_vcenter())
end

function draw_stage()
  local x = (game.current_combat.current_stage - 1) % 8 * stage_offset
  local y = flr(game.current_combat.current_stage / 9) * 16

  map(x, y, 0, 0, 16, 16)
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

function draw_round_timer()
  local elapsed = is_round_beginning() and 0 or time() - game.current_combat.round_start_time
  local remaining = ceil(round_duration - elapsed)
  local x = get_hcenter(remaining)
  print(remaining, x, 8, 7)
end

function draw_finish_him_her()
  if game.current_combat.timers.finishing_move > timers.finishing_move / 2 then
    local pronoun = game.current_combat.round_loser.character.g == gender.her and "her" or "him"
    local text = "finish " .. pronoun
    draw_blinking_text(text, get_hcenter(text), get_vcenter())
  end
end

function draw_round_start()
  local text = ""

  if game.current_combat.timers.round_start > timers.round_start / 2 then
    text = "round " .. game.current_combat.round
  else
    text = "fight"
  end

  draw_blinking_text(text, get_hcenter(text), get_vcenter())
end

function draw_round_result()
  local winner = game.current_combat.round_winner
  local text = (winner == p1 and "p1" or "p2") .. " wins"
  draw_blinking_text(text, get_hcenter(text), get_vcenter())
end

function draw_new_player()
  local text = "a new challenger has emerged"
  draw_blinking_text(text, get_hcenter(text), get_vcenter())
end

function draw_hp()
  local offset = 8
  local h = 8
  local w = (128 - offset * 3) / 2
  local y = offset * 2

  for p in all({ p1, p2 }) do
    local x = offset + p.id * w + p.id * offset
    local hp_w = w * p.hp / 100
    hp_w = hp_w < 1 and 1 or hp_w

    rectfill(x, y, x + w - 1, y + h - 1, 8)
    rectfill(x, y, x + hp_w - 1, y + h - 1, 11)
    rect(x, y, x + w - 1, y + h - 1, 6)

    for i = 1, game.current_combat.rounds_won[p.id] do
      change_pallete({ { 5, 0 } })
      spr(192, x + (i - 1) * 8, y + h + 2)
      pal()
    end
  end
end

function draw_blinking_text(s, x, y)
  print(s, x, y, get_blinking_color())
end

function draw_axis_debugger()
  if not ad then
    ad = { x = 0, y = 0 }
  else
    if btn(⬇️) then
      ad.y += 1
    elseif btn(⬅️) then
      ad.x -= 1
    elseif btn(⬆️) then
      ad.y -= 1
    elseif btn(➡️) then
      ad.x += 1
    end
  end

  pset(ad.x, ad.y, 7)
  print(ad.x, 0, 0)
  print(ad.y, 20, 0)
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