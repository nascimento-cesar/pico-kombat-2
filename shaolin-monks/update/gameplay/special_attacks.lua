function fire_projectile(p)
  p.projectile = p.projectile or string_to_hash("frames_counter,x,y", { 0, p.x + sprite_w * p.facing, p.y + 5 - ceil(p.character.projectile_h / 2) })
end

function flying_kick(p)
  -- problema na colisão no final da tela
  move_x(p, jump_speed * 1)
  p.is_orientation_locked = true
  -- attack(
  --   p, function()
  --     finish_action(p)
  --   end
  -- )
end