function handle_special_attack(p)
  string_to_hash("fire_projectile,jc_high_green_bolt,jc_shadow_kick,kl_diving_kick,kl_hat_toss,kl_spin,kl_teleport,lk_bicycle_kick,lk_flying_kick,sz_freeze", { fire_projectile, jc_high_green_bolt, jc_shadow_kick, kl_diving_kick, kl_hat_toss, kl_spin, kl_teleport, lk_bicycle_kick, lk_flying_kick, sz_freeze })[p.ca.handler](p)
end

function detect_special_attack(p, next_input)
  for _, special_attack in pairs(p.character.special_attacks) do
    local sequence, should_trigger = special_attack.sequence, false

    if (p.ca.is_aerial and special_attack.is_aerial) or (not p.ca.is_aerial and not special_attack.is_aerial) then
      if sub(sequence, 1, 1) == "h" and p.released_buttons then
        local released_buttons, released_buttons_timer = unpack_split(p.released_buttons)
        p.released_buttons, should_trigger = nil, released_buttons == sub(sequence, 3) and released_buttons_timer >= sub(sequence, 2)
      else
        local command = p.action_stack .. (p.action_stack ~= "" and "+" or "") .. next_input
        should_trigger = sub(command, #command - #sequence + 1, #command) == sequence
      end
    end

    if should_trigger then
      return special_attack.name
    end
  end
end

function fire_projectile(p, callback, collision_callback)
  if not p.cap.has_fired_projectile then
    p.projectile = p.projectile or string_to_hash("action,callback,collision_callback,frames,x,y", { p.ca, callback, collision_callback, 0, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
    p.cap.has_fired_projectile = true
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

function update_projectile(p)
  if p.projectile then
    local vs, action = get_vs(p), p.projectile.action

    p.projectile.x += (p.projectile.x_speed or projectile_speed) * p.facing
    p.projectile.frames += 1

    if p.projectile.callback then
      p.projectile.callback(p)
    end

    if has_collision(p.projectile.x, p.projectile.y, vs.x, vs.y, nil, 6) then
      deal_damage(action, vs, p.projectile.collision_callback)
      p.projectile = nil
    elseif is_limit_right(p.projectile.x) or is_limit_left(p.projectile.x) or (p.projectile.y > y_bottom_limit + sprite_h * 2) then
      p.projectile = nil
    end

    if not p.projectile and action.requires_forced_stop then
      finish_action(p)
    end
  end
end

function jc_high_green_bolt(p)
  fire_projectile(
    p, function(p)
      if is_timer_active(p.projectile, "up_timer", 10) and not p.projectile.top_height_reached then
        p.projectile.y /= 1.05
      else
        p.projectile.top_height_reached = true
      end
      if p.projectile.top_height_reached then
        p.projectile.y *= 1.05
      end
    end
  )
end

function jc_shadow_kick(p)
  if is_timer_active(p.cap, "kick_timer", 15) then
    attack(p)

    if p.cap.kick_timer > 8 then
      move_x(p, offensive_speed)
    end
  else
    finish_action(p)
  end
end

function kl_diving_kick(p)
  setup_next_action(p, "jump_kick", { direction = forward, is_landing = true, x_speed = offensive_speed }, true)
end

function kl_hat_toss(p)
  fire_projectile(
    p, function(p)
      if btn(⬆️, p.id) then
        p.projectile.y_speed = -0.75
      elseif btn(⬇️, p.id) then
        p.projectile.y_speed = 0.75
      end
      p.projectile.y += p.projectile.y_speed or 0
    end
  )
end

function kl_spin(p)
  if is_timer_active(p.cap, "spin_timer", 30) then
    attack(p)

    if p.cap.spin_timer < 20 then
      p.cap.boosts = p.cap.boosts or 0

      if btnp(⬆️, p.id) and p.cap.boosts < 3 then
        p.cap.spin_timer += 10
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

function lk_bicycle_kick(p)
  if p.cap.has_hit then
    if is_timer_active(p.cap, "hit_timer", 30) then
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

function sz_freeze(p)
  fire_projectile(
    p, nil, function(p)
      if p.st_frozen_timer <= 0 then
        p.st_frozen_timer = 60
      else
        p.st_frozen_timer = 0
        get_vs(p).st_frozen_timer = 60
      end
    end
  )
end