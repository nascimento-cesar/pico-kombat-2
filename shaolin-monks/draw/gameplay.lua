function draw_gameplay()
  cls(1)
  draw_stage()
  function_from_hash("countdown,finished,finishing_move,new_player", { draw_round_start, draw_round_result, draw_finish_him_her, draw_new_player }, current_combat.round_state)
  draw_round_timer()
  draw_hp()
  draw_player(p1)
  draw_player(p2)
end

function draw_stage()
  local x, y = (current_combat.current_stage - 1) % 8 * stage_offset, flr(current_combat.current_stage / 9) * 16
  map(x, y, 0, 0, 16, 16)
end

function draw_player(p)
  local flip_body_x, flip_body_y, flip_head_x, flip_head_y, head_x_adjustment, head_y_adjustment, sprites, body_id, head_id, index, sprite = false, false, false, false, 0, 0, p.current_action.sprites

  if is_action_state_eq(p, "held") then
    index = #sprites
  else
    index = flr(p.frames_counter / p.current_action.fps) + 1

    if is_action_state_eq(p, "released") then
      index = #sprites - index + 1
    end
  end

  sprite = sprites[index]

  if type(sprite) == "table" then
    body_id, head_id, head_x_adjustment, head_y_adjustment, flip_body_x, flip_body_y, flip_head_x, flip_head_y = sprite[1], sprite[2], sprite[3] or 0, sprite[4] or 0, sprite[5], sprite[6], sprite[7], sprite[8]
  else
    body_id, head_id = sprite, 1
  end

  if p.facing == backward then
    flip_body_x, flip_head_x = not flip_body_x, not flip_head_x
  end

  draw_head(p, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
  draw_body(p, body_id, flip_body_x, flip_body_y)

  if p.projectile then
    draw_projectile(p)
  end

  draw_particles(p)
end

function draw_head(p, id, x_adjustment, y_adjustment, flip_x, flip_y)
  shift_pal(p.character.head_pal_map)
  spr(p.character.head_sprites[id], p.x + x_adjustment * p.facing, p.y + y_adjustment, 1, 1, flip_x, flip_y)
  pal()
end

function draw_body(p, id, flip_x, flip_y)
  shift_pal(p.character.body_pal_map)
  spr(id, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function draw_projectile(p)
  local sprites, index = p.character.projectile_sprites, flr(p.projectile.frames_counter / p.character.projectile_fps) + 1

  if index > #sprites then
    index, p.projectile.frames_counter = 1, 0
  end

  shift_pal(p.character.projectile_pal_map)
  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, p.facing == backward)
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
  local elapsed = is_round_state_eq "countdown" and 0 or time() - current_combat.round_start_time
  local remaining = ceil(round_duration - elapsed)
  local x = get_hcenter(remaining)
  print(remaining, x, 8, 7)
end

function draw_finish_him_her()
  if current_combat.timers.finishing_move > timers.finishing_move / 2 then
    draw_blinking_text("finish " .. (current_combat.round_loser.character.gender == 1 and "him" or "her"))
  end
end

function draw_round_start()
  draw_blinking_text(current_combat.timers.round_start > timers.round_start / 2 and "round " .. current_combat.round or "fight")
end

function draw_round_result()
  draw_blinking_text((current_combat.round_winner == p1 and "p1" or "p2") .. " wins")
end

function draw_new_player()
  draw_blinking_text "a new challenger has emerged"
end

function draw_hp()
  local offset = 8
  local h, w, y = 8, (128 - offset * 3) / 2, offset * 2

  foreach_player(function(p, p_id)
    local x, hp_w = offset + p_id * w + p_id * offset, max(w * p.hp / 100, 1)
    rectfill(x, y, x + w - 1, y + h - 1, 8)
    rectfill(x, y, x + hp_w - 1, y + h - 1, 11)
    rect(x, y, x + w - 1, y + h - 1, 6)
    for i = 1, current_combat.rounds_won[p_id] do
      shift_pal "p50"
      spr(192, x + (i - 1) * 8, y + h + 2)
      pal()
    end
  end)
end