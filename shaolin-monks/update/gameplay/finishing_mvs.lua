function handle_finishing_mv(p, vs)
  local finishing_mv = ccp.finishing_mv

  if ccp.has_finishing_mv_started then
    if p.cap.is_dmg_sprite then
      ccp.has_finishing_mv_hit = true
      ccp.skip_p_rendering = vs.id
      ccp.p_fmr1 = create_temp_p(vs, finishing_mv.fmr1_fps, finishing_mv.fmr1_sprites)
      ccp.p_fmr2 = create_temp_p(vs, finishing_mv.fmr2_fps, finishing_mv.fmr2_sprites)

      -- update_player(ccp.p_fmr1)
      -- update_player(ccp.p_fmr2)
      -- start reac here
    end
  else
    local x_diff = p.facing == forward and vs.x - (p.x + sprite_w) or p.x - (vs.x + sprite_w)

    if x_diff > finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = forward }, true)
    elseif x_diff < finishing_mv.distance then
      setup_next_ac(p, "walk", { direction = backward }, true)
    else
      ccp.has_finishing_mv_started = true
      start_ac(p, finishing_mv)
    end
  end
end

function create_temp_p(p, fps, sprites)
  return {
    caf = 0,
    ca = {
      fps = fps,
      sprites = sprites
    },
    char = p.char,
    facing = p.facing,
    particle_sets = {},
    st_timers = p.st_timers,
    t = 0,
    x = p.x,
    y = p.y
  }
end