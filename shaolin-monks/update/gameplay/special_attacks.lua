function handle_special_attack(p)
  string_to_hash("fire_projectile,lk_bicycle_kick,lk_flying_kick", { fire_projectile, lk_bicycle_kick, lk_flying_kick })[p.ca.handler](p)
end

function detect_special_attack(p)
  for _, special_attack in pairs(p.character.special_attacks) do
    local sequence, should_trigger = special_attack.sequence, false

    if (p.ca.is_aerial and special_attack.is_aerial) or (not p.ca.is_aerial and not special_attack.is_aerial) then
      if sub(sequence, 1, 1) == "h" and p.released_buttons then
        local released_buttons, released_buttons_timer = unpack_split(p.released_buttons)
        p.released_buttons, should_trigger = nil, released_buttons == sub(sequence, 3) and released_buttons_timer >= sub(sequence, 2)
      else
        should_trigger = sub(p.action_stack, #p.action_stack - #sequence + 1, #p.action_stack) == sequence
      end
    end

    if should_trigger then
      cleanup_action_stack(p, true)

      return special_attack
    end
  end
end

function fire_projectile(p)
  p.projectile = p.projectile or string_to_hash("action,frames,x,y", { p.ca, 0, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
end

function update_projectile(p)
  if p.projectile then
    local vs = get_vs(p)

    p.projectile.x += projectile_speed * p.facing
    p.projectile.frames += 1

    if has_collision(p.projectile.x, p.projectile.y, vs.x, vs.y, nil, 6) then
      deal_damage(p.projectile.action, vs)
      p.projectile = nil
    elseif is_limit_right(p.projectile.x) or is_limit_left(p.projectile.x) then
      p.projectile = nil
    end
  end
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