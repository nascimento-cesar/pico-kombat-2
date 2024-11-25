function handle_special_attack(p)
  local handler, params = unpack_split(p.ca.handler, "#")

  if handler == "st_morph" then
    return st_morph(p, params)
  end

  string_to_hash("fire_projectile,slide,jc_high_green_bolt,jc_nut_cracker,jc_shadow_kick,jc_uppercut,jx_back_breaker,jx_gotcha,jx_ground_pound,kl_diving_kick,kl_hat_toss,kl_spin,kl_teleport,kn_fan_lift,kn_flying_punch,lk_bicycle_kick,lk_flying_kick,rp_force_ball,rp_invisibility,sz_freeze", { fire_projectile, slide, jc_high_green_bolt, jc_nut_cracker, jc_shadow_kick, jc_uppercut, jx_back_breaker, jx_gotcha, jx_ground_pound, kl_diving_kick, kl_hat_toss, kl_spin, kl_teleport, kn_fan_lift, kn_flying_punch, lk_bicycle_kick, lk_flying_kick, rp_force_ball, rp_invisibility, sz_freeze })[handler](p)
end

function detect_special_attack(p, next_input)
  for _, special_attack in pairs(p.character.special_attacks) do
    local sequence, should_trigger = special_attack.sequence, false

    if (p.ca.is_aerial and special_attack.is_aerial) or (not p.ca.is_aerial and not special_attack.is_aerial) then
      if sub(sequence, 1, 1) == "h" and p.released_buttons then
        local released_buttons, released_buttons_timer = unpack_split(p.released_buttons)
        p.released_buttons, should_trigger = nil, released_buttons == sub(sequence, 3) and released_buttons_timer >= sub(sequence, 2)
      else
        local command = p.action_stack .. (p.action_stack ~= "" and "+" or "") .. (next_input or "")
        should_trigger = sub(command, #command - #sequence + 1, #command) == sequence
      end
    end

    if should_trigger then
      return special_attack.name
    end
  end
end

function destroy_projectile(p)
  p.projectile = nil
end

function fire_projectile(p, timer, before_callback, after_callback, collision_callback)
  if not p.cap.has_fired_projectile then
    p.projectile = p.projectile or string_to_hash("action,after_callback,before_callback,collision_callback,frames,params,timer,x,y", { p.ca, after_callback, before_callback, collision_callback, 0, p.cap, timer, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
    p.cap.has_fired_projectile = true
  end
end

function update_projectile(p)
  if p.projectile then
    local vs, action, params = get_vs(p), p.projectile.action, p.projectile.params

    if p.projectile.before_callback then
      p.projectile.before_callback(p)
    end

    p.projectile.x += (p.projectile.x_speed or projectile_speed) * p.facing
    p.projectile.frames += 1

    if has_collision(p.projectile.x, p.projectile.y, vs.x, vs.y, nil, 6) then
      deal_damage(action, params, vs)

      if p.projectile.collision_callback then
        p.projectile.collision_callback(p)
      else
        destroy_projectile(p)
      end
    elseif is_limit_right(p.projectile.x) or is_limit_left(p.projectile.x) or (p.projectile.y > y_bottom_limit + sprite_h * 2) then
      destroy_projectile(p)
    end

    if p.projectile then
      if p.projectile.after_callback then
        p.projectile.after_callback(p)
      end

      if p.projectile.timer and not is_timer_active(p.projectile, "timer") then
        destroy_projectile(p)
      end
    end

    if not p.projectile and p.ca.requires_forced_stop then
      finish_action(p)
    end
  end
end

function slide(p)
  if is_timer_active(p.cap, "action_timer", 15) then
    attack(p)

    if p.cap.action_timer > 8 then
      move_x(p, offensive_speed)
    end
  else
    finish_action(p)
  end
end

function teleport(p)
  local vs = get_vs(p)

  if not p.cap.has_teleported then
    if p.y < y_bottom_limit + (sprite_h * 2) + stroke_width then
      move_y(p, jump_speed)
    else
      p.x = vs.x - sprite_w * vs.facing
      p.facing *= -1
      p.cap.has_teleported = true
      fix_players_orientation()
    end
  else
    finish_action(p, actions.jump)
  end
end

function jc_high_green_bolt(p)
  fire_projectile(
    p, nil, function(p)
      if p.projectile.top_height_reached then
        p.projectile.y *= 1.05
      else
        p.projectile.y /= 1.05
        p.projectile.top_height_reached = p.projectile.y <= y_upper_limit
      end
    end
  )
end

function jc_nut_cracker(p)
  if is_timer_active(p.cap, "action_timer", 15) then
    attack(p)
  else
    finish_action(p)
  end
end

function jc_shadow_kick(p)
  slide(p)
end

function jc_uppercut(p)
  if p.cap.top_height_reached then
    if not is_timer_active(p.cap, "action_timer", 3) then
      finish_action(p, actions.jump)
    end
  else
    attack(p)
    move_x(p, 1)
    move_y(p, -offensive_speed)
    p.cap.top_height_reached = p.y <= y_upper_limit
  end
end

function jx_back_breaker(p)
  attack(p)

  if p.cap.has_hit then
    local vs = get_vs(p)
    vs.y = p.y - (vs.caf > 8 and 5 or 6)
    vs.x = p.x
  else
    setup_next_action(p, "jump", p.cap, true)
  end
end

function jx_gotcha(p)
  local vs, max_punches_landed = get_vs(p)

  if p.cap.has_hit then
    p.cap.punches, p.cap.max_punches = p.cap.punches or 1, p.cap.max_punches or 2
    local is_last_punch = p.cap.punches >= p.cap.max_punches

    if btnp(🅾️, p.id) and p.held_buttons ~= "🅾️" then
      p.cap.max_punches = 3
    end

    if not is_timer_active(p.cap, "grab_timer", 10) then
      setup_next_action(
        p, "punch", {
          is_x_shiftable = 0,
          skip_reaction = not is_last_punch,
          next_action = is_last_punch and actions.idle or p.character.special_attacks["gotcha"],
          next_action_params = is_last_punch and {} or { punches = p.cap.punches + 1 },
          reaction = is_last_punch and "thrown_backward"
        }, true
      )
    end
  else
    if not is_timer_active(p.cap, "action_timer", 15) and vs.ca ~= actions.grabbed then
      finish_action(p)
    else
      attack(p)
    end
  end
end

function jx_ground_pound(p)
  if is_timer_active(p.cap, "action_timer", 20) then
    attack(
      p, function(p)
        local vs = get_vs(p)
        vs.cap.reaction_callback = function(p)
          move_x(p, -1)
          if not is_timer_active(p.cap, "reaction_timer", 15) then
            finish_action(p)
          end
        end
      end,
      function(p)
        return get_vs(p).y == y_bottom_limit
      end
    )
  else
    finish_action(p)
  end
end

function kl_diving_kick(p)
  setup_next_action(p, "jump_kick", { direction = forward, is_landing = true, x_speed = offensive_speed }, true)
end

function kl_hat_toss(p)
  fire_projectile(
    p, nil, function(p)
      if btn(⬆️, p.id) then
        p.projectile.y -= 0.75
      elseif btn(⬇️, p.id) then
        p.projectile.y += 0.75
      end
    end
  )
end

function kl_spin(p)
  if is_timer_active(p.cap, "action_timer", 30) then
    attack(p)

    if p.cap.action_timer < 20 then
      p.cap.boosts = p.cap.boosts or 0

      if btnp(⬆️, p.id) and p.cap.boosts < 3 then
        p.cap.action_timer += 10
        p.cap.boosts += 1
      end
    end
  else
    finish_action(p)
  end
end

function kl_teleport(p)
  teleport(p)
end

function kn_fan_lift(p)
  fire_projectile(
    p, 30, function(p)
      p.projectile.x_speed = 0
    end, nil, function(p)
      local vs = get_vs(p)
      vs.cap.reaction_callback = function(p)
        if not is_timer_active(p.cap, "reaction_timer", 60) then
          finish_action(p, actions.fall)
        elseif p.cap.reaction_timer > 50 then
          move_x(vs, -1)
          move_y(vs, -1)
        end
      end
    end
  )
end

function kn_flying_punch(p)
  if p.cap.has_hit then
    finish_action(p)
  else
    attack(p)

    if p.cap.top_height_reached then
      if is_timer_active(p.cap, "action_timer", 15) then
        move_x(p, offensive_speed * 1.5)
      else
        finish_action(p, actions.jump)
      end
    else
      move_y(p, -offensive_speed * 1.5)
      p.cap.top_height_reached = p.y <= y_upper_limit + sprite_h
    end
  end
end

function lk_bicycle_kick(p)
  if p.cap.has_hit then
    if is_timer_active(p.cap, "action_timer", 30) then
      move_x(p, offensive_speed / 2)
      move_x(get_vs(p), -1)
    else
      finish_action(p)
      finish_action(get_vs(p))
      move_x(get_vs(p), -1)
    end
  else
    move_x(p, offensive_speed)
    attack(p)
  end
end

function lk_flying_kick(p)
  if p.cap.has_hit then
    finish_action(p)
  else
    move_x(p, offensive_speed)
    attack(p)
  end
end

function rp_force_ball(p)
  fire_projectile(
    p, 90, function(p)
      p.projectile.x_speed = 0.5
    end
  )
end

function rp_invisibility(p)
  if not is_timer_active(p.cap, "action_timer", 10) then
    p.st_timers.invisible = 300
  end
end

function st_morph(p, id)
  if not is_st_eq(p, "morphed") then
    p.is_morphed = true
    p.st_timers.morphed = 300
    p.character = characters[tonum(id)]
  end
end

function sz_freeze(p)
  fire_projectile(
    p, nil, nil, nil, function(p)
      local vs = get_vs(p)
      if not is_st_eq(vs, "frozen") then
        vs.st_timers.frozen = 60
      else
        vs.st_timers.frozen = 0
        p.st_timers.frozen = 60
      end
      destroy_projectile(p)
    end
  )
end