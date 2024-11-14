function fix_players_orientation()
  if (p1.facing == p2.facing or is_p1_ahead_p2()) and not p1.ca.is_aerial and not p2.ca.is_aerial then
    shift_player_orientation(p1, p1.x < p2.x and forward or backward)
    shift_player_orientation(p2, p1.x < p2.x and backward or forward)
  end
end

function fix_players_placement()
  if not p1.ca.is_aerial and not p2.ca.is_aerial then
    if p1.x < sprite_w and p2.x < sprite_w then
      if p1.facing == forward then
        p1.x = map_min_x
        p2.x = sprite_w
      else
        p1.x = sprite_w
        p2.x = map_min_x
      end
    end

    if p1.x + sprite_w > map_max_x - sprite_w + 2 and p2.x + sprite_w > map_max_x - sprite_w + 2 then
      if p1.facing == forward then
        p1.x = map_max_x - (sprite_w - 1) * 2
        p2.x = map_max_x - (sprite_w - 1)
      else
        p1.x = map_max_x - (sprite_w - 1)
        p2.x = map_max_x - (sprite_w - 1) * 2
      end
    end
  end
end

function move_x(p, x_increment, direction)
  local vs = get_vs(p)
  local direction = direction or p.facing
  local new_p_x = p.x + x_increment * direction
  local has_l_col, has_r_col = has_collision(new_p_x, p.y, vs.x, vs.y, "left"), has_collision(new_p_x, p.y, vs.x, vs.y, "right")

  if is_limit_left(new_p_x) then
    p.x = map_min_x
  elseif is_limit_right(new_p_x) then
    p.x = map_max_x - sprite_w + 1
  elseif has_l_col then
    local vs_x_increment = new_p_x - vs.x - sprite_w + 1

    if not is_limit_left(vs.x + vs_x_increment + 1) then
      if not vs.ca.is_aerial then
        move_x(vs, vs_x_increment)
      end

      p.x = new_p_x
    end
  elseif has_r_col then
    local vs_x_increment = vs.x - new_p_x - sprite_w + 1

    if not is_limit_right(vs.x - vs_x_increment - 1) then
      if not vs.ca.is_aerial then
        move_x(vs, vs_x_increment)
      end

      p.x = new_p_x
    end
  else
    p.x = new_p_x
  end
end

function move_y(p, y)
  p.y += y
end

function shift_player_orientation(p, facing)
  if not p.ca.is_special_attack and not is_frozen(p) then
    p.facing = facing or p.facing * -1
  end
end

function shift_player_x(p, shift_direction)
  if shift_direction and not p.is_x_shifted then
    move_x(p, x_shift * shift_direction)
    p.is_x_shifted = shift_direction
  elseif not shift_direction and p.is_x_shifted then
    move_x(p, x_shift * -p.is_x_shifted)
    p.is_x_shifted = false
  end
end

function shift_player_y(p, shift_direction)
  if shift_direction and not p.is_y_shifted then
    move_y(p, y_shift * shift_direction, nil, true)
    p.is_y_shifted = shift_direction
  elseif not shift_direction and p.is_y_shifted then
    move_y(p, y_shift * -p.is_y_shifted)
    p.is_y_shifted = false
  end
end