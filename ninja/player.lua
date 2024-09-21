function player_update()
  player.dt_x *= friction
  player.dt_y += gravity

  if btn(⬅️) then
    player.dt_x -= player.acc_x
    player.running = true
    player.flp = true
  end

  if btn(➡️) then
    player.dt_x += player.acc_x
    player.running = true
    player.flp = false
  end

  if player.running
      and not btn(⬅️)
      and not btn(➡️)
      and not player.falling
      and not player.jumping then
    player.running = false
    player.sliding = true
  end

  if btnp(❎)
      and player.landed then
    player.dt_y -= player.acc_y
    player.landed = false
  end

  if player.dt_y > 0 then
    player.falling = true
    player.landed = false
    player.jumping = false

    player.dt_y = limit_speed(player.dt_y, player.md_y)

    if collide_map(player, "down", 0) then
      player.landed = true
      player.falling = false
      player.dt_y = 0
      player.y -= (player.y + player.h + 1) % 8 - 1

      --------test-------
      collide_d = "yes"
    else
      collide_d = "no"
      -------------------
    end
  end

  if player.dt_y < 0 then
    player.jumping = true

    if collide_map(player, "up", 1) then
      player.dt_y = 0

      --------test-------
      collide_u = "yes"
    else
      collide_u = "no"
      -------------------
    end
  end

  if player.dt_x < 0 then
    player.dt_x = limit_speed(player.dt_x, player.md_x)

    if collide_map(player, "left", 1) then
      player.dt_x = 0

      --------test-------
      collide_l = "yes"
    else
      collide_l = "no"
      -------------------
    end
  end

  if player.dt_x > 0 then
    player.dt_x = limit_speed(player.dt_x, player.md_x)

    if collide_map(player, "right", 1) then
      player.dt_x = 0

      --------test-------
      collide_r = "yes"
    else
      collide_r = "no"
      -------------------
    end
  end

  if player.sliding then
    if abs(player.dt_x) < .2
        or player.running then
      player.dt_x = 0
      player.sliding = false
    end
  end

  player.x += player.dt_x
  player.y += player.dt_y

  if player.x < map_start then
    player.x = map_start
  end

  if player.x > map_end - player.w then
    player.x = map_end - player.w
  end
end

function player_animate()
  if player.jumping then
    player.sp = 7
  elseif player.falling then
    player.sp = 8
  elseif player.sliding then
    player.sp = 9
  elseif player.running then
    if time() - player.anim > .1 then
      player.anim = time()
      player.sp += 1
      if player.sp > 6 then
        player.sp = 3
      end
    end
  else
    if time() - player.anim > .3 then
      player.anim = time()
      player.sp += 1
      if player.sp > 2 then
        player.sp = 1
      end
    end
  end
end

function limit_speed(num, maximum)
  return mid(-maximum, num, maximum)
end

function player_camera()
  cam_x = player.x - 64 + player.w / 2

  if cam_x < map_start then
    cam_x = map_start
  end

  if cam_x > map_end - 128 then
    cam_x = map_end - 128
  end

  camera(cam_x, 0)
end