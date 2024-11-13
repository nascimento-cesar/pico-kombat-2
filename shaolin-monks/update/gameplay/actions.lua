function perform_action(p, action_name, callback)
  if action_name then
    local is_not_eq_prev = not is_action_eq(p, action_name)

    if sub(action_name, 1, 1) == "*" then
      perform_special_attack(p, sub(action_name, 2))
    elseif action_name == "attack" then
      local vs, full_sprite_w = get_vs(p), sprite_w + 1

      if is_player_attacking(p) and has_collision(p.x, p.y, vs.x, vs.y, nil, full_sprite_w) then
        if vs.is_blocking then
        else
          deal_damage(p.ca, vs)
          p.cap.is_player_attacking = false

          if callback then
            callback()
          end
        end
      elseif is_action_type_eq(p, "special_attack") and (is_limit_left(p.x) or is_limit_right(p.x)) then
        finish_action(p)
      end
    elseif action_name == "flinch" and is_not_eq_prev then
      start_action(p, actions.flinch)
      move_x(p, -flinch_speed)
    elseif action_name == "frozen" then
      if p.frozen_timer <= 0 then
        p.frozen_timer = 60
      else
        p.frozen_timer = 0
        perform_action(get_vs(p), "frozen")
      end
    elseif action_name == "propelled_back" and not is_action_eq(p, "propelled") then
      start_action(p, actions.propelled, { direction = backward, is_propelled_back = true })
    elseif action_name == "propelled_up" and not is_action_eq(p, "propelled") then
      start_action(p, actions.propelled, { direction = backward })
    elseif action_name == "stumble" and is_not_eq_prev then
      start_action(p, actions.stumble)
    elseif action_name == "swept" and is_not_eq_prev then
      move_x(p, -swept_speed)
      start_action(p, actions.swept)
    elseif action_name == "walk" then
      move_x(p, walk_speed * p.cap.direction)
    end
  end
end