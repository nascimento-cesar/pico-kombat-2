function fire_projectile(p)
  p.projectile = p.projectile or string_to_hash("frames_counter,x,y", { 0, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
end

function lk_bicycle_kick(p)
  shift_player_y(p, false, true)
  move_x(p, offensive_speed, nil, true)
  attack(
    p, function()
      finish_action(p)
    end
  )
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