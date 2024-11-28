function attack(p, collision_callback, reaction_callback, collision_handler)
  local vs = get_vs(p)
  local should_hit = collision_handler and collision_handler(p, vs) or has_collision(p.x, p.y, vs.x, vs.y)

  if should_hit and not p.cap.has_hit and not p.cap.has_blocked then
    if vs.ca == actions.block then
      p.cap.has_blocked = true
      sfx(actions.block.hit_sfx)
      deal_damage(vs, 1)
    else
      if p.ca.hit_sfx then
        sfx(p.ca.hit_sfx)
      end

      p.cap.has_hit = true
      hit(p.ca, p.cap, vs)

      if collision_callback then
        collision_callback(p, vs)
      end

      vs.cap.reaction_callback = reaction_callback
    end
  end
end

function check_defeat(p)
  if is_round_state_eq "finishing_move" then
    combat_round_state = "finished"
  elseif p.hp <= 0 then
    local vs = get_vs(p)
    combat_rounds_won[vs.id] += 1
    combat_round_loser, combat_round_winner, combat_round_state = p, vs, has_combat_ended() and "finishing_move" or "finished"
  end
end

function deal_damage(p, dmg)
  p.hp -= dmg
  -- check_defeat(p)
end

function hit(action, params, p)
  local reaction = params.reaction or action.reaction

  if reaction and not params.skip_reaction then
    if p.ca.is_aerial and any_match("flinch,swept", reaction) then
      setup_next_action(p, "thrown_backward", nil, true)
    else
      setup_next_action(p, reaction, nil, true)
    end

    remove_temporary_conditions(p)
  end

  if action.spills_blood then
    spill_blood(p)
  end

  deal_damage(p, action.dmg)
end

function has_collision(a_x, a_y, t_x, t_y, type, a_w, a_h, t_w, t_h)
  local a_w, a_h, t_w, t_h = a_w or sprite_w, a_h or sprite_h, t_w or sprite_w, t_h or sprite_h
  local has_r_col, has_l_col, has_u_col, has_d_col = a_x + a_w > t_x and a_x < t_x, a_x < t_x + t_w and a_x > t_x, t_y + t_h > a_y and t_y <= a_y, a_y + a_h > t_y and t_y >= a_y

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
  add(p.particle_sets, build_particle_set(8, 30, p.facing == forward and p.x + sprite_w or p.x, p.y))
end