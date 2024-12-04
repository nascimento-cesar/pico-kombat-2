function fix_players_orientation()
  if (p1.facing == p2.facing or is_p1_ahd_p2()) and not p1.ca.is_aerial and not p2.ca.is_aerial then
    shift_player_orientation(p1, p1.x < p2.x and forward or backward)
    shift_player_orientation(p2, p1.x < p2.x and backward or forward)
  end
end

function move_x(p, x_increment, direction)
  local vs, direction = get_vs(p), direction or p.facing
  local new_p_x = p.x + x_increment * direction
  local has_l_col, has_r_col = has_collision(new_p_x, p.y, vs.x, vs.y, "left"), has_collision(new_p_x, p.y, vs.x, vs.y, "right")

  if is_limit_left(new_p_x) then
    if is_limit_left(vs.x) then
      p.x = vs.x + sprite_w
    else
      p.x = map_min_x

      if has_r_col then
        vs.x = p.x + sprite_w
      end
    end
  elseif is_limit_right(new_p_x) then
    if is_limit_right(vs.x) then
      p.x = vs.x - sprite_w
    else
      p.x = map_max_x - sprite_w + 1

      if has_l_col then
        vs.x = p.x - sprite_w
      end
    end
  elseif has_l_col and not p.is_x_shifted then
    p.x = vs.x + sprite_w
  elseif has_r_col and not p.is_x_shifted then
    p.x = vs.x - sprite_w
  else
    p.x = new_p_x
  end
end

function move_y(p, y)
  p.y += y
end

function shift_player_orientation(p, facing)
  if not p.ca.is_special_atk and not is_st_eq(p, "frozen") then
    p.facing = facing or p.facing * -1
  end
end

function shift_player_x(p, shift_direction)
  if shift_direction and not p.is_x_shifted then
    p.is_x_shifted = shift_direction
    move_x(p, x_shift * shift_direction)
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