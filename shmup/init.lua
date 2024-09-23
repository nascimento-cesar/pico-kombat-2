function _init()
  set_global_vars()
  set_flags()
  set_sprites()
  set_sounds()
  set_ship()
  set_bullets()
  set_stars()
  set_enemies()
  -- set_explosions()
  set_particles()
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
  initial_x = flr(map_w / 2)
  initial_y = map_h - tile_h * 2
  invincibility_frames = 0
  modes = {
    game = 0,
    start = 1,
    over = 2
  }
  current_mode = modes.start
  game_title = "big c awesome shmup"
  text_blink_color = 5
end

function set_flags()
  flags = {}
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
    -- explosion = { 64, 66, 68, 70, 72 }
  }
end

function set_sounds()
  sounds = {
    fire = 0,
    hit = 1,
    hit_kill = 2,
    damage = 3
  }
end

function set_ship()
  ship = {
    x = initial_x,
    y = initial_y,
    speed = 1.5,
    sprite = sprites.ship.default,
    thruster_sprite_i = 1
  }
end

function set_bullets()
  bullet_speed = 4
  bullet_ratio = 6
  bullet_cooldown = bullet_ratio
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
    x = flr(rnd(128 - tile_w)),
    y = -tile_h,
    points = 100,
    flashing_speed = 0,
    hp = 2
  }
  add(enemies, new_enemy)
end

-- function set_explosions()
--   explosions = {}
-- end

function set_particles()
  particles = {}
  particle_palletes = {
    enemy = { 7, 9, 8, 2 },
    ship = { 7, 14, 1, 2 }
  }
end