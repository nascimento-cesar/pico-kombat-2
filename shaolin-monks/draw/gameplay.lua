function draw_gameplay()
  cls()

  if cb_round_state == "boss_defeated" then
    if ccp.defeat_animation_step == 1 then
      shift_pal "p07172737475767778797a7b7c7d7e7f7"
      draw_stage()
      pal()
      draw_players()
    else
      draw_stage()
      draw_players()

      if ccp.defeat_animation_step == 3 then
        draw_blinking_text "evil emperor has fallen!"
      end
    end
  else
    draw_stage()
    function_lookup("finished,finishing_mv,new_player,starting,time_up", { draw_finished, draw_finishing_mv, draw_new_player, draw_starting, draw_time_up }, cb_round_state)
    print(cb_round_remaining_time, get_hcenter(cb_round_remaining_time), 8, 7)
    local offset = 8
    local h, w, y = 8, (128 - offset * 3) / 2, offset * 2

    foreach_player(function(p, p_id)
      local x, hp_w = offset + p_id * w + p_id * offset, max(w * p.hp / 100, 1)
      rectfill(x, y, x + w - 1, y + h - 1, 8)
      rectfill(x, y, x + hp_w - 1, y + h - 1, 11)
      rect(x, y, x + w - 1, y + h - 1, 6)
      for i = 1, cb_rounds_won[p_id] do
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
  palt(0, false)
  map(0, 0, 0, 0, 16, 16)
  pal()
end

function draw_player(p)
  if ccp.skip_p_rendering == p.id then
    if ccp.has_finishing_mv_hit then
      draw_player(ccp.p_fmr1)
      draw_player(ccp.p_fmr2)
    end

    return
  end

  local flip_bd_x, flip_bd_y, flip_hd_x, flip_hd_y, hd_x_adjustment, hd_y_adjustment, sprite, bd_id, hd_id, index = false, false, false, false, 0, 0, p.ca.sprites[flr((p.caf - 1) / p.ca.fps) + 1]

  if type(sprite) == "table" then
    bd_id, hd_id, hd_x_adjustment, hd_y_adjustment, flip_bd_x, flip_bd_y, flip_hd_x, flip_hd_y = sprite[1], sprite[2], sprite[3] or 0, sprite[4] or 0, sprite[5], sprite[6], sprite[7], sprite[8]
  else
    bd_id, hd_id = sprite, 1
  end

  if p.facing == backward then
    flip_bd_x, flip_hd_x = not flip_bd_x, not flip_hd_x
  end

  if not is_st_eq(p, "invisible") then
    local hd_x, hd_y = p.x + hd_x_adjustment * p.facing, p.y + hd_y_adjustment

    draw_stroke(p, bd_id, flip_bd_x, flip_bd_y, hd_id, hd_x, hd_y, flip_hd_x, flip_hd_y)
    shift_pal(is_st_eq(p, "frozen") and frozen_hd_pal_map or p.char.hd_pal_map)
    spr(p.char.hd_sprites[hd_id], hd_x, hd_y, 1, 1, flip_hd_x, flip_hd_y)
    pal()
    shift_pal(is_st_eq(p, "frozen") and frozen_bd_pal_map or p.char.bd_pal_map)
    spr(bd_id, p.x, p.y, 1, 1, flip_bd_x, flip_bd_y)
    pal()
  end

  draw_particles(p)
end

function draw_stroke(p, bd_id, flip_bd_x, flip_bd_y, hd_id, hd_x, hd_y, flip_hd_x, flip_hd_y)
  shift_pal "p01112131415161718191a1b1c1d1e1f1"

  for axes in all(split "0|-1,-1|-1,-1|0,-1|1,0|1,1|1,1|0,1|-1") do
    local x, y = unpack_split(axes, "|")

    if bd_id then
      spr(bd_id, p.x + x, p.y + y, 1, 1, flip_bd_x, flip_bd_y)
    end

    if hd_id then
      spr(p.char.hd_sprites[hd_id], hd_x + x, hd_y + y, 1, 1, flip_hd_x, flip_hd_y)
    end
  end

  pal()
end

function draw_projectile(p)
  local sprites, index = p.projectile.sprites, flr(p.projectile.frames / p.char.projectile_fps) + 1

  if index > #sprites then
    index, p.projectile.frames = 1, 0
  end

  shift_pal(p.char.projectile_pal_map)
  spr(sprites[index], p.projectile.x, p.projectile.y, 1, 1, p.projectile.flip_x or p.projectile.direction == backward)
  pal()

  if p.projectile.has_rope then
    local y = p.projectile.y + (p.char.projectile_h / 2)
    line(p.x + sprite_w, y, p.projectile.rope_x, y, 4)
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

function draw_finishing_mv()
  if cb_round_timers.finishing_mv > round_timers.finishing_mv / 2 then
    draw_blinking_text("finish " .. (cb_round_loser.char.gender == 1 and "him" or "her"))
  end
end

function draw_starting()
  draw_blinking_text(cb_round_timers.starting > round_timers.starting / 2 and "round " .. cb_round or "fight")
end

function draw_finished()
  draw_blinking_text(cb_round_winner and ((cb_round_winner == p1 and "p1" or "p2") .. " wins") or "draw")
end

function draw_new_player()
  draw_blinking_text "a new challenger has emerged"
end

function draw_time_up()
  draw_blinking_text "time's up"
end