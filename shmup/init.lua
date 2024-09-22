function _init()
  set_global_vars()
  set_sprites()
  set_ship()
  set_bullets()
  set_stars()
  set_enemies()
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
    enemy = { 17, 18, 17, 19, 17 },
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

function set_bullets()
  bullet_speed = 4
  bullets = {}
end

function set_stars()
  stars = {}
  local star_count = 100

  for i = 1, star_count do
    local new_star = {
      x = random_axis(),
      y = random_axis(),
      speed = rnd(1.5) + 0.5
    }
    add(stars, new_star)
  end
end

function set_enemies()
  enemies = {}
  local new_enemy = {
    sprite_i = 1,
    x = random_axis(),
    y = 20
  }
  add(enemies, new_enemy)
end