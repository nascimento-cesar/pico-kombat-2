function collide_map(obj, direction, flag)
  local x = obj.x
  local y = obj.y
  local w = obj.w
  local h = obj.h

  local x1, y1, x2, y2 = 0

  if direction == "left" then
    x1 = x - 1
    y1 = y
    x2 = x
    y2 = y + h - 1
  elseif direction == "right" then
    x1 = x + w - 1
    y1 = y
    x2 = x + w
    y2 = y + h - 1
  elseif direction == "up" then
    x1 = x + 2
    y1 = y - 1
    x2 = x + w - 3
    y2 = y
  elseif direction == "down" then
    x1 = x + 2
    y1 = y + h
    x2 = x + w - 3
    y2 = y + h
  end

  --------test-------
  x1r = x1
  y1r = y1
  x2r = x2
  y2r = y2
  -------------------

  x1 /= 8
  y1 /= 8
  x2 /= 8
  y2 /= 8

  if fget(mget(x1, y1), flag)
      or fget(mget(x2, y1), flag)
      or fget(mget(x1, y2), flag)
      or fget(mget(x2, y2), flag) then
    return true
  end

  return false
end