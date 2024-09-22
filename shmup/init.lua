function _init()
  set_global_vars()
  set_sprites()
  set_ship()
  set_bullet()
  set_stars()
end

function set_global_vars()
  map_h = 127
  map_w = 127
  tile_h = 8
  tile_w = 8
  muzzle_r = 5
  score = 0
  max_lives = 3
  lives = 3
  modes = {
    game = 0,
    start = 1,
    over = 2
  }
  current_mode = modes.start
  game_title = "big c awesome shmup"
  current_blink_color = 5
end

function set_sprites()
  sprites = {
    ship = {
      default = 2,
      left = 1,
      right = 3
    },
    bullet = {
      default = 16
    },
    thruster = { 4, 5, 4, 6, 4 },
    lives = {
      default = 7,
      empty = 8
    }
  }
end

function set_ship()
  ship = {
    x = map_w / 2,
    y = map_h / 2,
    speed = 1,
    sprite = sprites.ship.default,
    thruster_sprite_i = 1
  }
end

function set_bullet()
  bullet = {
    x = map_w / 2,
    y = map_h / 2,
    speed = 4,
    muzzle_r = muzzle_r
  }
end

function set_stars()
  stars = {
    count = 100,
    x = {},
    y = {},
    speed = {}
  }

  for i = 1, stars.count do
    add(stars.x, flr(rnd(128)))
    add(stars.y, flr(rnd(128)))
    add(stars.speed, rnd(1.5) + 0.5)
  end
end