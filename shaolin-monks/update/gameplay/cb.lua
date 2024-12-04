function attack(p, collision_callback, reac_callback, block_callback, collision_handler)
  if cb_round_state == "finished" then
    return
  end

  local vs, should_hit, block_callback = get_vs(p), false, p.cap.block_callback or block_callback

  if (collision_handler and collision_handler(p, vs) or has_collision(p.x, p.y, vs.x, vs.y, p.facing == forward and "right" or "left", 12, 12, 12, 12)) and (not p.ca.dmg_sprite or (p.ca.dmg_sprite and p.cap.is_dmg_sprite)) then
    should_hit = true
  end

  if should_hit and not p.cap.has_hit and not p.cap.has_blocked then
    if vs.ca == acs.block then
      p.cap.has_blocked = true
      play_sfx(acs.block.hit_sfx)
      deal_damage(vs, 1)

      if block_callback then
        block_callback(p, vs)
      end
    else
      if p.ca.hit_sfx and not p.cap.skip_sfx then
        play_sfx(p.ca.hit_sfx)
      end

      p.cap.has_hit = true
      hit(p.ca, p.cap, vs)

      if collision_callback then
        collision_callback(p, vs)
      end

      vs.cap.reac_callback = reac_callback
    end
  end
end

function check_defeat(p)
  if p.hp <= 0 then
    if is_round_state_eq "finishing_move" then
      cb_round_state = "finished"
    else
      increment_rounds_won(get_vs(p))

      local has_cb_ended, _, loser = get_cb_result()

      if has_cb_ended then
        cb_round_state = is_boss(loser) and "boss_defeated" or "finishing_move"
      else
        cb_round_state = "finished"
      end
    end
  end
end

function deal_damage(p, dmg)
  p.hp -= dmg
  check_defeat(p)
end

function hit(ac, params, p)
  local reac = params.reac or ac.reac

  if reac and not params.skip_reac then
    if p.ca.is_aerial and (reac == "flinch" or reac == "swept") then
      setup_next_ac(p, "thrown_backward", nil, true)
    else
      setup_next_ac(p, reac, nil, true)
    end

    remove_temporary_conditions(p)
  end

  if ac.spills_blood then
    spill_blood(p)
  end

  deal_damage(p, ac.dmg)
end

function has_collision(a_x, a_y, t_x, t_y, type, a_w, a_h, t_w, t_h)
  local a_w, a_h, t_w, t_h = a_w or sprite_w, a_h or sprite_h, t_w or sprite_w, t_h or sprite_h
  local has_r_col, has_l_col, has_u_col, has_d_col = a_x + a_w > t_x and a_x <= t_x, a_x < t_x + t_w and a_x >= t_x, t_y + t_h > a_y and t_y <= a_y, a_y + a_h > t_y and t_y >= a_y

  if type == "left" then
    return has_l_col and (has_u_col or has_d_col)
  elseif type == "right" then
    return has_r_col and (has_u_col or has_d_col)
  else
    return (has_r_col or has_l_col) and (has_u_col or has_d_col)
  end
end

function remove_temporary_conditions(p)
  p.st_timers.frozen = 0
end

function spill_blood(p)
  build_particle_set(p, 8, 30, p.facing == forward and p.x + sprite_w or p.x, p.y)
end