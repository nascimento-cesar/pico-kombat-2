function _init()
  map_h = 127
  map_w = 127
  tile_h = 8
  tile_w = 8
  muzzle_r = 5
  score = 0
  max_lives = 3
  lives = 3

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

  ship = {
    x = map_w / 2,
    y = map_h / 2,
    speed = 1,
    sprite = sprites.ship.default,
    thruster_sprite_i = 1
  }

  bullet = {
    x = map_w / 2,
    y = map_h / 2,
    speed = 4,
    muzzle_r = muzzle_r
  }

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