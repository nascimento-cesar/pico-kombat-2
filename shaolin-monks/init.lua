function _init()
  define_global_variables()
  define_game()
  define_global_actions()
  define_characters()
  define_players()
  disable_hold_function()
end

function define_global_variables()
  action_states = {
    finished = 1,
    held = 2,
    in_progress = 3,
    released = 4
  }
  action_types = {
    aerial = 1,
    aerial_attack = 2,
    attack = 3,
    damage_reaction = 4,
    movement = 5,
    other = 6,
    special_attack = 7
  }
  debug = {}
  directions = {
    backward = -1,
    forward = 1
  }
  flinch_speed = 3
  jump_speed = 2
  projectile_speed = 3
  round_start_countdown = 3
  screens = {
    character_selection = 1,
    game_over = 2,
    gameplay = 3,
    start = 4
  }
  sprite_h = 8
  sprite_w = 7
  swept_speed = 3
  walk_speed = 1
  x_shift = 3
  y_shift = 3
  y_bottom_limit = 127 - 32
  y_upper_limit = 127 - 32 - 20
end

function define_game()
  game = {
    action_stack_timeout_frames = 0,
    current_round = 1,
    current_screen = screens.start,
    round_start_countdown = 3
  }
end

function define_characters()
  characters = {
    lk = {
      head_sprites = { 64, 65, 66, 67, 68, 69, 68 },
      pallete_map = {
        { 1, 15 },
        { 2, 8 },
        { 3, 8 },
        { 4, 8 },
        { 5, 0 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 0 },
        { 13, 0 },
        { 14, 8 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, { 19, 7 } }, fire_projectile)
      }
    },
    kl = {
      head_sprites = { 70, 71, 72, 73, 70, 70, 74 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 0 },
        { 4, 0 },
        { 5, 0 },
        { 8, 5 },
        { 9, 15 },
        { 10, 8 },
        { 11, 8 },
        { 12, 1 },
        { 13, 8 },
        { 14, 0 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    jc = {
      head_sprites = { 75, 76, 77, 78, 75, 75, 75 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 15 },
        { 4, 1 },
        { 5, 0 },
        { 8, 4 },
        { 9, 1 },
        { 10, 0 },
        { 11, 1 },
        { 12, 0 },
        { 13, 1 },
        { 14, 1 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = { { 8, 3 }, { 9, 11 }, { 10, 11 }, { 7, 11 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        shadow_bolt = create_special_attack("shadow_bolt", "⬇️➡️🅾️", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    rp = {
      head_sprites = { 79, 80, 81, 82, 79, 79, 102 },
      head_pallete_map = { { 1, 3 }, { 2, 4 }, { 5, 0 }, { 8, 3 }, { 9, 8 } },
      pallete_map = {
        { 1, 15 },
        { 2, 3 },
        { 4, 3 },
        { 5, 0 },
        { 8, 3 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 0 },
        { 13, 0 },
        { 14, 3 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = { { 8, 3 }, { 9, 11 }, { 10, 11 }, { 7, 11 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        shadow_bolt = create_special_attack("shadow_bolt", "➡️➡️🅾️", { 29, { 30, 7 } }, fire_projectile)
      }
    },
    sz = {
      head_sprites = { 79, 80, 81, 82, 79, 79, 79 },
      pallete_map = {
        { 1, 15 },
        { 2, 12 },
        { 3, 12 },
        { 4, 12 },
        { 5, 0 },
        { 8, 12 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 0 },
        { 13, 0 },
        { 14, 12 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    st = {
      head_sprites = { 83, 84, 85, 86, 83, 83, 83 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 15 },
        { 4, 5 },
        { 5, 0 },
        { 8, 5 },
        { 9, 15 },
        { 11, 5 },
        { 12, 0 },
        { 13, 10 },
        { 14, 15 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    kn = {
      head_sprites = { 87, 88, 89, 90, 87, 87, 87 },
      pallete_map = {
        { 1, 15 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 0 },
        { 8, 1 },
        { 9, 5 },
        { 10, 0 },
        { 11, 0 },
        { 12, 1 },
        { 13, 0 },
        { 14, 1 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    jx = {
      head_sprites = { 91, 92, 93, 94, 91, 91, 91 },
      pallete_map = {
        { 1, 4 },
        { 2, 8 },
        { 3, 4 },
        { 4, 8 },
        { 5, 0 },
        { 8, 5 },
        { 9, 5 },
        { 10, 6 },
        { 11, 6 },
        { 12, 0 },
        { 13, 6 },
        { 14, 4 },
        { 15, 4 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    ml = {
      head_sprites = { 87, 88, 89, 90, 87, 87, 87 },
      pallete_map = {
        { 1, 15 },
        { 2, 2 },
        { 3, 2 },
        { 4, 2 },
        { 5, 0 },
        { 8, 2 },
        { 9, 5 },
        { 10, 0 },
        { 11, 0 },
        { 12, 2 },
        { 13, 0 },
        { 14, 2 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    bk = {
      head_sprites = { 95, 96, 97, 98, 95, 95, 95 },
      pallete_map = {
        { 1, 6 },
        { 2, 0 },
        { 3, 15 },
        { 4, 8 },
        { 5, 0 },
        { 8, 6 },
        { 9, 15 },
        { 10, 7 },
        { 11, 8 },
        { 12, 0 },
        { 13, 7 },
        { 14, 15 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    sc = {
      head_sprites = { 79, 80, 81, 82, 79, 79, 79 },
      pallete_map = {
        { 1, 15 },
        { 2, 10 },
        { 3, 10 },
        { 4, 10 },
        { 5, 0 },
        { 8, 10 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 0 },
        { 13, 0 },
        { 14, 10 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    },
    rd = {
      head_sprites = { 99, 100, 100, 101, 99, 99, 99 },
      pallete_map = {
        { 1, 15 },
        { 2, 12 },
        { 3, 12 },
        { 4, 12 },
        { 5, 0 },
        { 6, 6 },
        { 8, 13 },
        { 9, 7 },
        { 10, 0 },
        { 11, 0 },
        { 12, 7 },
        { 13, 0 },
        { 14, 12 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        -- fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    }
  }
end

function define_global_actions()
  actions = {
    block = create_action("block", 2, nil, true, false, { 10, 11 }, action_types.other),
    crouch = create_action("crouch", 2, nil, true, false, { { 4, 1, 0, 1 }, { 5, 1, 0, 2 } }, action_types.other),
    flinch = create_action("flinch", 6, flinch, false, false, { 23 }, action_types.damage_reaction),
    flying_kick = create_action("flying_kick", 3, attack, false, false, { { 14, 6 } }, action_types.aerial_attack),
    flying_punch = create_action("flying_punch", 3, attack, false, false, { { 15, 6 } }, action_types.aerial_attack),
    get_up = create_action("get_up", 2, nil, false, false, { { 5, 1, 0, 2 }, { 4, 1, 0, 1 } }, action_types.other),
    hook = create_action("hook", 3, attack, false, true, { { 6, 1, 0, 1 }, { 7, 2 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 7, 2 } }, action_types.attack),
    idle = create_action("idle", 1, nil, false, false, { 0 }, action_types.other),
    jump = create_action("jump", 2, nil, false, false, { { 16, 6, 0, 2 }, { 17, 4, 2, 1 }, { 16, 6, 0, -2, true, true, true, true }, { 17, 4, -2, -1, true, true, true, true } }, action_types.aerial),
    kick = create_action("kick", 4, attack, false, true, { { 12, 5 }, { 13, 6 }, { 12, 5 } }, action_types.attack),
    prone = create_action("prone", 8, nil, false, false, { { 22, 4, -4, 0, false, false, true, true } }, action_types.other),
    propelled = create_action("propelled", 3, nil, true, false, { { 23, 6, 0, 0 }, { 24, 4, -4, 0, false, false, true, true } }, action_types.damage_reaction),
    punch = create_action("punch", 3, attack, false, true, { { 7, 2 }, { 9, 3 }, { 7, 2 } }, action_types.attack),
    roundhouse_kick = create_action("roundhouse_kick", 2, attack, false, true, { { 7, 2 }, { 28, 3, -1 }, { 7, 2, 0, 0, true, false, true, false }, { 12, 5 }, { 13, 6 }, { 13, 6 }, { 13, 6 }, { 12, 5 } }, action_types.attack),
    sweep = create_action("sweep", 2, attack, false, true, { { 4, 1, 0, 1 }, { 25, 2, 0, 1 }, { 26, 3, -1, 1 }, { 25, 2, 0, 1, true, false, true, false }, { 27, 1, 0, 1 }, { 27, 1, 0, 1 }, { 4, 1, 0, 1 } }, action_types.attack),
    swept = create_action("swept", 4, nil, false, false, { { 21, 6, 0, 1 } }, action_types.damage_reaction),
    walk = create_action("walk", 4, walk, false, false, { 1, 2, 3, 2 }, action_types.movement)
  }
end

function create_action(name, frames_per_sprite, handler, is_holdable, is_x_shiftable, sprites, type)
  return {
    frames_per_sprite = frames_per_sprite,
    handler = handler,
    is_holdable = is_holdable,
    is_x_shiftable = is_x_shiftable,
    name = name,
    sprites = sprites,
    type = type
  }
end

function create_special_attack(name, sequence, sprites, handler)
  return {
    action = create_action(name, 4, handler, false, false, sprites, action_types.special_attack),
    sequence = sequence
  }
end

function define_players()
  p1 = create_player(0, characters.rp, false, true)
  p2 = create_player(1, characters.jx, false)
end

function create_player(id, character, is_npc, is_challenger)
  return {
    action_stack = "",
    character = character,
    current_action = actions.idle,
    current_action_params = {},
    current_action_state = action_states.in_progress,
    current_projectile = nil,
    facing = is_challenger and directions.backward or directions.forward,
    frames_counter = 0,
    hp = 100,
    id = id,
    is_npc = is_npc or false,
    is_orientation_locked = false,
    is_x_shifted = false,
    jump_acceleration = 0,
    particle_sets = {},
    x = is_challenger and 127 - 36 - sprite_w or 36,
    y = y_bottom_limit
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end