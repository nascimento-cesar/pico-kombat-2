function fire_projectile(p)
  p.projectile = p.projectile or string_to_hash("frames_counter,x,y", { 0, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
end

function lk_bicycle_kick(p)
  if p.cap.has_hit then
    p.cap.hit_timer = p.cap.hit_timer or 30

    if p.cap.hit_timer <= 0 then
      finish_action(p)
      start_action(get_vs(p), actions.flinch)
      move_x(get_vs(p), -1, nil)
    else
      move_x(p, offensive_speed / 2, nil)
      move_x(get_vs(p), -1, nil)
      p.cap.hit_timer -= 1
    end
  else
    shift_player_y(p, false, true)
    move_x(p, offensive_speed, nil, true)
    attack(
      p, function()
        p.cap.has_hit = true
      end
    )
  end
end

function lk_flying_kick(p)
  shift_player_y(p, false, true)
  move_x(p, offensive_speed, nil, true)
  attack(
    p, function()
      finish_action(p)
    end
  )
end