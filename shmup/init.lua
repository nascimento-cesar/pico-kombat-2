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
  set_shockwaves()
  set_waves()
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
  current_wave = 0
  wave_time = 0
  max_waves = 4
  default_wave_time = 45
  wave_sound_played = false
  default_offensive_delay = 30
  offensive_delay = default_offensive_delay
  default_show_screen_delay = 30
  show_screen_delay = default_show_screen_delay
  start_button_released = false
  modes = {
    game = 0,
    start = 1,
    over = 2,
    wave = 3,
    victory = 4
  }
  enemy_types = {
    green_alien = "green_alien",
    flaming_guy = "flaming_guy",
    spinning_ship = "spinning_ship",
    boss = "boss"
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
    enemies = {
      [enemy_types.green_alien] = { size = 1, i = { 17, 18, 17, 19, 17 } },
      [enemy_types.flaming_guy] = { size = 1, i = { 148, 149, 148 } },
      [enemy_types.spinning_ship] = { size = 1, i = { 184, 185, 186, 187, 184 } },
      [enemy_types.boss] = { size = 2, i = { 208, 210, 208 } }
    },
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
    damage = 3,
    wave_start = 4
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

function set_enemies(type)
  enemies = {}
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

function set_shockwaves()
  shockwaves = {}
end

function set_waves()
  waves = {
    w1 = {
      { enemy_types.green_alien, enemy_types.green_alien, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.green_alien, enemy_types.green_alien },
      { enemy_types.green_alien, enemy_types.green_alien, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.green_alien, enemy_types.green_alien },
      { enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien }
    },
    w2 = {
      { enemy_types.green_alien, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.green_alien },
      { enemy_types.green_alien, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.green_alien },
      { enemy_types.green_alien, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.green_alien },
      { enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien }
    },
    w3 = {
      { enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy, enemy_types.flaming_guy },
      { enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship, enemy_types.spinning_ship },
      { enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien, enemy_types.green_alien }
    },
    b1 = {
      { enemy_types.boss }
    }
  }
end