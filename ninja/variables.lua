function _init()
  player = {
    sp = 1,
    x = 59,
    y = 59,
    w = 8,
    h = 8,
    flp = false,
    dt_x = 0,
    dt_y = 0,
    md_x = 2,
    md_y = 3,
    acc_x = 0.5,
    acc_y = 4,
    anim = 0,
    running = false,
    jumping = false,
    falling = false,
    sliding = false,
    landed = false
  }

  gravity = 0.3
  friction = 0.85

  cam_x = 0
  map_start = 0
  map_end = 1024

  --------test-------
  x1r = 0
  y1r = 0
  x2r = 0
  y2r = 0
  collide_l = "no"
  collide_r = "no"
  collide_u = "no"
  collide_d = "no"
  -------------------
end