function draw_gameplay()
  cls()

  if combat_round_state == "boss_defeated" then
    if combat_round_loser.defeat_animation_step == 1 then
      shift_pal "p07172737475767778797a7b7c7d7e7f7"
      draw_stage()
      pal()
      draw_players()
    else
      draw_stage()
      draw_players()

      if combat_round_loser.defeat_animation_step == 3 then
        draw_blinking_text "evil emperor has fallen!"
      end
    end
  else
    draw_stage()
    function_lookup("finished,finishing_move,new_player,starting,time_up", { draw_finished, draw_finishing_move, draw_new_player, draw_starting, draw_time_up }, combat_round_state)
    print(combat_round_remaining_time, get_hcenter(combat_round_remaining_time), 8, 7)
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

    draw_players()

    if p1.projectile then
      draw_projectile(p1)
    end

    if p2.projectile then
      draw_projectile(p2)
    end
  end
end

function draw_players()
  if p1.cap.has_hit then
    draw_player(p2)
    draw_player(p1)
  else
    draw_player(p1)
    draw_player(p2)
  end
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
    local head_x, head_y = p.x + head_x_adjustment * p.facing, p.y + head_y_adjustment
    shift_pal "p01112131415161718191a1b1c1d1e1f1"

    for axes in all(split "0|-1,-1|-1,-1|0,-1|1,0|1,1|1,1|0,1|-1") do
      local x, y = unpack_split(axes, "|")
      spr(body_id, p.x + x, p.y + y, 1, 1, flip_body_x, flip_body_y)
      spr(p.character.head_sprites[head_id], head_x + x, head_y + y, 1, 1, flip_head_x, flip_head_y)
    end

    pal()
    shift_pal(is_st_eq(p, "frozen") and frozen_head_pal_map or p.character.head_pal_map)
    spr(p.character.head_sprites[head_id], head_x, head_y, 1, 1, flip_head_x, flip_head_y)
    pal()
    shift_pal(is_st_eq(p, "frozen") and frozen_body_pal_map or p.character.body_pal_map)
    spr(body_id, p.x, p.y, 1, 1, flip_body_x, flip_body_y)
    pal()
  end

  draw_particles(p)
end

function draw_projectile(p)
  local sprites, index = p.projectile.sprites, flr(p.projectile.frames / p.character.projectile_fps) + 1

  if index > #sprites then
    index, p.projectile.frames = 1, 0
  end

  shift_pal(p.character.projectile_pal_map)
  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, p.projectile.flip_x or p.facing == backward)
  pal()

  if p.projectile.has_rope then
    local y = p.projectile.y + (p.character.projectile_h / 2)
    line(p.x + sprite_w, y, p.projectile.x, y, 4)
  end
end

function draw_particles(p)
  for particle_set in all(p.particle_sets) do
    for particle in all(particle_set.particles) do
      particle.x += particle.speed_x
      particle.y += particle.speed_y
      local handler = flr_rnd(2) == 1 and circ or circfill
      handler(particle.x, particle.y, particle_set.radius or 0, particle_set.color)
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

function draw_finishing_move()
  if combat_round_timers.finishing_move > round_timers.finishing_move / 2 then
    draw_blinking_text("finish " .. (combat_round_loser.character.gender == 1 and "him" or "her"))
  end
end

function draw_starting()
  draw_blinking_text(combat_round_timers.starting > round_timers.starting / 2 and "round " .. combat_round or "fight")
end

function draw_finished()
  draw_blinking_text(combat_round_winner and ((combat_round_winner == p1 and "p1" or "p2") .. " wins") or "draw")
end

function draw_new_player()
  draw_blinking_text "a new challenger has emerged"
end

function draw_time_up()
  draw_blinking_text "time's up"
end