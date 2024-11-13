function attack(p, collision_callback)
  local vs, full_sprite_w = get_vs(p), sprite_w + 1

  if is_player_attacking(p) and has_collision(p.x, p.y, vs.x, vs.y, nil, full_sprite_w) then
    if vs.is_blocking then
    else
      deal_damage(p.current_action, vs)
      p.current_action_params.is_player_attacking = false

      if collision_callback then
        collision_callback()
      end
    end
  elseif is_limit_left(p.x) or is_limit_right(p.x) then
    finish_action(p)
  end
end

function flinch(p)
  if not is_action_eq(p, "flinch") then
    start_action(p, actions.flinch)
    move_x(p, -flinch_speed)
  end
end

function frozen(p)
  if p.frozen_timer <= 0 then
    p.frozen_timer = 60
  else
    p.frozen_timer = 0
    frozen(get_vs(p))
  end
end

function propelled_back(p)
  if not is_action_eq(p, "propelled") then
    start_action(p, actions.propelled, { direction = backward, is_propelled_back = true })
  end
end

function propelled_up(p)
  if not is_action_eq(p, "propelled") then
    start_action(p, actions.propelled, { direction = backward })
  end
end

function swept(p)
  if not is_action_eq(p, "swept") then
    move_x(p, -swept_speed)
    start_action(p, actions.swept)
  end
end

function walk(p)
  move_x(p, walk_speed * p.current_action_params.direction)
end