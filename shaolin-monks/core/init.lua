function _init()
  define_global_variables()
  define_game()
  define_global_actions()
  define_bosses()
  define_characters()
  define_players()
  disable_hold_function()
end

function define_global_variables()
  action_stack_timeout = 6

  bs = {
    kr = 1,
    sk = 2
  }
  debug = {}
  directions = {
    backward = -1,
    forward = 1
  }
  flinch_speed = 3
  gender = {
    him = 1,
    her = 2
  }
  jump_speed = 2
  p_id = {
    p1 = 0,
    p2 = 1
  }
  projectile_speed = 3
  round_duration = 90
  sprite_h = 8
  sprite_w = 7
  stage_offset = 16
  stages_number = 9
  swept_speed = 3
  timers = {
    finishing_move = 90,
    new_player = 60,
    round_end = 60,
    round_start = 60
  }
  walk_speed = 1
  x_shift = 3
  y_shift = 2
  y_bottom_limit = 127 - 36
  y_upper_limit = 127 - 36 - 20
end

function define_game()
  game = {
    current_combat = nil,
    current_screen = "start",
    joined_status = {
      [p_id.p1] = false,
      [p_id.p2] = false
    },
    next_combats = {
      [p_id.p1] = {},
      [p_id.p2] = {}
    }
  }
end

function define_bosses()
  bosses = {
    [bs.sk] = {
      head_sprites = { 103, 104, 105, 106, 103, 103, 103 },
      pallete_map = {
        { 1, 15 },
        { 3, 15 },
        { 4, 6 },
        { 5, 2 },
        { 9, 6 },
        { 10, 13 },
        { 11, 5 },
        { 12, 15 },
        { 14, 15 }
      },
      projectile = {
        frames_per_sprite = 2,
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {}
    }
  }
end

function define_characters()
  characters = {
    [1] = {
      background_color = 2,
      head_pallete_map = { { 5, 0 } },
      head_sprites = { 64, 65, 66, 67, 68, 69, 68 },
      pallete_map = {
        { 1, 15 },
        { 2, 8 },
        { 3, 8 },
        { 4, 8 },
        { 5, 15 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 0 },
        { 13, 0 },
        { 14, 8 }
      },
      projectile = {
        frames_per_sprite = 2,
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        fireball = create_special_attack("fireball", "➡️➡️🅾️", { 18, { 19, 7 } }, fire_projectile)
      }
    },
    [2] = {
      background_color = 3,
      head_pallete_map = { { 5, 0 }, { 8, 5 } },
      head_sprites = { 70, 71, 72, 73, 70, 70, 74 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 0 },
        { 4, 0 },
        { 5, 15 },
        { 9, 15 },
        { 10, 8 },
        { 11, 8 },
        { 12, 1 },
        { 13, 8 },
        { 14, 0 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = { { 5, 0 }, { 13, 5 } },
        sprites = { 58, 59, 60, 61, 60, 59 }
      },
      special_attacks = {
        hat_toss = create_special_attack("hat_toss", "⬅️➡️🅾️", { 18, 20 }, fire_projectile)
      }
    },
    [3] = {
      background_color = 13,
      head_pallete_map = { { 5, 0 }, { 8, 4 } },
      head_sprites = { 75, 76, 77, 78, 75, 75, 75 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 15 },
        { 4, 1 },
        { 5, 15 },
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
    [4] = {
      background_color = 4,
      head_pallete_map = { { 1, 3 }, { 2, 4 }, { 5, 0 }, { 8, 3 }, { 9, 8 } },
      head_sprites = { 79, 80, 81, 82, 79, 79, 102 },
      pallete_map = {
        { 1, 15 },
        { 2, 3 },
        { 4, 3 },
        { 5, 15 },
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
        acid_spit = create_special_attack("acid_spit", "➡️➡️🅾️", { 29, { 30, 7 } }, fire_projectile)
      }
    },
    [5] = {
      background_color = 1,
      head_pallete_map = { { 5, 0 }, { 8, 12 } },
      head_sprites = { 79, 80, 81, 82, 79, 79, 79 },
      pallete_map = {
        { 1, 15 },
        { 2, 12 },
        { 3, 12 },
        { 4, 12 },
        { 5, 15 },
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
        pallete_map = { { 8, 7 }, { 9, 12 }, { 10, 12 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        freeze = create_special_attack("freeze", "⬇️➡️🅾️", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    [6] = {
      background_color = 8,
      head_pallete_map = { { 5, 0 }, { 8, 5 } },
      head_sprites = { 83, 84, 85, 86, 83, 83, 83 },
      pallete_map = {
        { 1, 15 },
        { 2, 0 },
        { 3, 15 },
        { 4, 5 },
        { 5, 15 },
        { 9, 15 },
        { 11, 5 },
        { 12, 0 },
        { 13, 10 },
        { 14, 15 }
      },
      projectile = {
        frames_per_sprite = 2,
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        fire_skull = create_special_attack("fire_skull", "⬅️⬅️🅾️", { 18, { 19, 7 } }, fire_projectile)
      }
    },
    [7] = {
      background_color = 12,
      g = gender.her,
      head_pallete_map = { { 5, 0 }, { 8, 1 } },
      head_sprites = { 87, 88, 89, 90, 87, 87, 87 },
      pallete_map = {
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 1 },
        { 8, 1 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 15 },
        { 13, 0 },
        { 14, 1 }
      },
      projectile = {
        frames_per_sprite = 2,
        height = 5,
        sprites = { 52, 53, 54, 55, 54, 53 }
      },
      special_attacks = {
        fan_throw = create_special_attack("fan_throw", "➡️➡️🅾️", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    [8] = {
      background_color = 14,
      head_pallete_map = { { 5, 0 }, { 8, 5 }, { 15, 4 } },
      head_sprites = { 91, 92, 93, 94, 91, 91, 91 },
      pallete_map = {
        { 1, 4 },
        { 2, 8 },
        { 3, 4 },
        { 4, 8 },
        { 5, 4 },
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
        pallete_map = { { 8, 2 }, { 9, 14 }, { 10, 7 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        energy_wave = create_special_attack("energy_wave", "➡️⬇️⬅️❎", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    [9] = {
      background_color = 13,
      g = gender.her,
      head_pallete_map = { { 5, 0 }, { 8, 2 } },
      head_sprites = { 87, 88, 89, 90, 87, 87, 87 },
      pallete_map = {
        { 1, 2 },
        { 3, 2 },
        { 4, 2 },
        { 5, 2 },
        { 8, 2 },
        { 9, 15 },
        { 10, 0 },
        { 11, 0 },
        { 12, 15 },
        { 13, 0 },
        { 14, 2 }
      },
      projectile = {
        frames_per_sprite = 2,
        pallete_map = {},
        sprites = { 56 }
      },
      special_attacks = {
        sai_throw = create_special_attack("sai_throw", "⬇️⬅️🅾️", { 18, { 19, 7 } }, fire_projectile)
      }
    },
    [10] = {
      background_color = 14,
      head_sprites = { 95, 96, 97, 98, 95, 95, 95 },
      pallete_map = {
        { 1, 6 },
        { 2, 0 },
        { 3, 15 },
        { 4, 8 },
        { 5, 15 },
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
        pallete_map = { { 8, 13 }, { 9, 6 }, { 10, 6 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        blade_spark = create_special_attack("blade_spark", "⬇️⬅️🅾️", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    [11] = {
      background_color = 2,
      head_pallete_map = { { 5, 0 }, { 8, 10 } },
      head_sprites = { 79, 80, 81, 82, 79, 79, 79 },
      pallete_map = {
        { 1, 15 },
        { 2, 10 },
        { 3, 10 },
        { 4, 10 },
        { 5, 15 },
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
        pallete_map = { { 5, 0 } },
        sprites = { 57 }
      },
      special_attacks = {
        spear = create_special_attack("spear", "⬅️⬅️🅾️", { 18, { 20, 7 } }, fire_projectile)
      }
    },
    [12] = {
      background_color = 1,
      head_pallete_map = { { 8, 13 } },
      head_sprites = { 99, 100, 100, 101, 99, 99, 99 },
      pallete_map = {
        { 1, 15 },
        { 2, 12 },
        { 3, 12 },
        { 4, 12 },
        { 5, 15 },
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
        pallete_map = { { 8, 12 }, { 9, 7 }, { 10, 7 } },
        sprites = { 48, 49, 50, 51, 50, 49 }
      },
      special_attacks = {
        lightning = create_special_attack("lightning", "⬇️➡️🅾️", { 18, { 19, 7 } }, fire_projectile)
      }
    }
  }
end

function define_global_actions()
  actions = {
    block = create_action("block", 2, nil, true, false, { 10, 11 }, "other"),
    crouch = create_action("crouch", 2, nil, true, false, { { 4, 1, 0, 1 }, { 5, 1, 0, 2 } }, "other"),
    flinch = create_action("flinch", 6, flinch, false, false, { 23 }, "damage_reaction"),
    flying_kick = create_action("flying_kick", 3, attack, false, false, { { 14, 6 } }, "aerial_attack", propelled, 10),
    flying_punch = create_action("flying_punch", 3, attack, false, false, { { 15, 6 } }, "aerial_attack", flinch, 10),
    get_up = create_action("get_up", 2, nil, false, false, { { 5, 1, 0, 2 }, { 4, 1, 0, 1 } }, "other"),
    hook = create_action("hook", 3, attack, false, true, { { 6, 1, 0, 1 }, { 7, 2 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 8, 3 }, { 7, 2 } }, "attack", propelled, 100),
    idle = create_action("idle", 1, nil, false, false, { 0 }, "other"),
    jump = create_action("jump", 2, nil, false, false, { { 16, 6, 0, 2 }, { 17, 4, 2, 1 }, { 16, 6, 0, -2, true, true, true, true }, { 17, 4, -2, -1, true, true, true, true } }, "aerial"),
    kick = create_action("kick", 4, attack, false, true, { { 12, 5 }, { 13, 6 }, { 12, 5 } }, "attack", flinch, 10),
    prone = create_action("prone", 8, nil, false, false, { { 22, 4, -4, 0, false, false, true, true } }, "other"),
    propelled = create_action("propelled", 3, nil, true, false, { { 23, 6, 0, 0 }, { 24, 4, -4, 0, false, false, true, true } }, "damage_reaction"),
    punch = create_action("punch", 3, attack, false, true, { { 7, 2 }, { 9, 3 }, { 7, 2 } }, "attack", flinch, 10),
    roundhouse_kick = create_action("roundhouse_kick", 2, attack, false, true, { { 7, 2 }, { 28, 3, -1 }, { 7, 2, 0, 0, true, false, true, false }, { 12, 5 }, { 13, 6 }, { 13, 6 }, { 13, 6 }, { 12, 5 } }, "attack", propelled, 20),
    sweep = create_action("sweep", 2, attack, false, true, { { 4, 1, 0, 1 }, { 25, 2, 0, 1 }, { 26, 3, -1, 1 }, { 25, 2, 0, 1, true, false, true, false }, { 27, 1, 0, 1 }, { 27, 1, 0, 1 }, { 4, 1, 0, 1 } }, "attack", swept, 10),
    swept = create_action("swept", 4, nil, false, false, { { 21, 6, 0, 1 } }, "damage_reaction"),
    walk = create_action("walk", 4, walk, false, false, { 1, 2, 3, 2 }, "movement")
  }
end

function create_action(name, frames_per_sprite, handler, is_holdable, is_x_shiftable, sprites, type, reaction_handler, damage)
  return {
    damage = damage,
    frames_per_sprite = frames_per_sprite,
    handler = handler,
    is_holdable = is_holdable,
    is_x_shiftable = is_x_shiftable,
    name = name,
    reaction_handler = reaction_handler,
    sprites = sprites,
    type = type
  }
end

function create_special_attack(name, sequence, sprites, handler, reaction_handler, damage)
  return {
    action = create_action(
      name,
      4,
      handler,
      false,
      false,
      sprites,
      "special_attack",
      reaction_handler or flinch,
      damage or 20
    ),
    sequence = sequence
  }
end

function define_players()
  p1 = create_player(p_id.p1)
  p2 = create_player(p_id.p2)
end

function create_player(id, character)
  local is_p1 = id == p_id.p1

  return {
    action_stack = "",
    action_stack_timeout = action_stack_timeout,
    character = character,
    current_action = actions.idle,
    current_action_params = {},
    current_action_state = "in_progress",
    current_projectile = nil,
    facing = is_p1 and directions.forward or directions.backward,
    frames_counter = 0,
    highlighted_char = is_p1 and 1 or 4,
    hp = 100,
    id = id,
    is_orientation_locked = false,
    is_x_shifted = false,
    is_y_shifted = false,
    jump_acceleration = 0,
    particle_sets = {},
    x = is_p1 and 36 or 127 - 36 - sprite_w,
    y = y_bottom_limit
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end