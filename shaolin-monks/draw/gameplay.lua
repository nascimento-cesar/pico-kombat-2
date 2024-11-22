function draw_gameplay()
  cls()
  draw_stage()
  function_lookup("countdown,finished,finishing_move,new_player", { draw_round_start, draw_round_result, draw_finish_him_her, draw_new_player }, combat_round_state)
  draw_round_timer()
  draw_hp()
  draw_player(p1)
  draw_player(p2)
end

function draw_stage()
  local x, y = (combat_stage - 1) % 8 * stage_offset, flr(combat_stage / 9) * 16
  map(x, y, 0, 0, 16, 16)
end

function draw_player(p)
  local flip_body_x, flip_body_y, flip_head_x, flip_head_y, head_x_adjustment, head_y_adjustment, sprite, body_id, head_id, index = false, false, false, false, 0, 0, p.ca.sprites[flr((p.caf - 1) / p.ca.fps) + 1]

  if type(sprite) == "table" then
    body_id, head_id, head_x_adjustment, head_y_adjustment, flip_body_x, flip_body_y, flip_head_x, flip_head_y = sprite[1], sprite[2], sprite[3] or 0, sprite[4] or 0, sprite[5], sprite[6], sprite[7], sprite[8]
  else
    body_id, head_id = sprite, 1
  end

  if p.facing == backward then
    flip_body_x, flip_head_x = not flip_body_x, not flip_head_x
  end

  if not is_st_eq(p, "invisible") then
    draw_stroke(p, body_id, flip_body_x, flip_body_y, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
    draw_head(p, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
    draw_body(p, body_id, flip_body_x, flip_body_y)
  end

  if p.projectile then
    draw_projectile(p)
  end

  draw_particles(p)
end

function draw_stroke(p, body_id, flip_body_x, flip_body_y, head_id, head_x_adjustment, head_y_adjustment, flip_head_x, flip_head_y)
  local pal_string, body_x, body_y, head_x, head_y = "p", p.x, p.y, p.x + head_x_adjustment * p.facing, p.y + head_y_adjustment

  for i in all(split "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f") do
    pal_string = pal_string .. i .. "5"
  end

  shift_pal(pal_string)

  for axes in all(split "0|-1,-1|-1,-1|0,-1|1,0|1,1|1,1|0,1|-1") do
    local x, y = unpack_split(axes, "|")
    spr(body_id, body_x + x, body_y + y, 1, 1, flip_body_x, flip_body_y)
    spr(p.character.head_sprites[head_id], head_x + x, head_y + y, 1, 1, flip_head_x, flip_head_y)
  end

  pal()
end

function draw_head(p, id, x_adjustment, y_adjustment, flip_x, flip_y)
  shift_pal(is_st_eq(p, "frozen") and frozen_head_pal_map or p.character.head_pal_map)
  spr(p.character.head_sprites[id], p.x + x_adjustment * p.facing, p.y + y_adjustment, 1, 1, flip_x, flip_y)
  pal()
end

function draw_body(p, id, flip_x, flip_y)
  shift_pal(is_st_eq(p, "frozen") and frozen_body_pal_map or p.character.body_pal_map)
  spr(id, p.x, p.y, 1, 1, flip_x, flip_y)
  pal()
end

function draw_projectile(p)
  local sprites, index = p.character.projectile_sprites, flr(p.projectile.frames / p.character.projectile_fps) + 1

  if index > #sprites then
    index, p.projectile.frames = 1, 0
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
  local elapsed = is_round_state_eq "countdown" and 0 or time() - combat_round_start_time
  local remaining = ceil(round_duration - elapsed)
  local x = get_hcenter(remaining)
  print(remaining, x, 8, 7)
end

function draw_finish_him_her()
  if combat_round_timers.finishing_move > timers.finishing_move / 2 then
    draw_blinking_text("finish " .. (combat_round_loser.character.gender == 1 and "him" or "her"))
  end
end

function draw_round_start()
  draw_blinking_text(combat_round_timers.round_start > timers.round_start / 2 and "round " .. combat_round or "fight")
end

function draw_round_result()
  draw_blinking_text((combat_round_winner == p1 and "p1" or "p2") .. " wins")
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
    for i = 1, combat_rounds_won[p_id] do
      shift_pal "p50"
      spr(192, x + (i - 1) * 8, y + h + 2)
      pal()
    end
  end)
end