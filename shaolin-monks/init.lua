function _init()
  define_global_variables()
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
  pixel_shift = 2
  projectile_speed = 3
  sprite_h = 8
  sprite_w = 8
  walk_speed = 1
  y_bottom_limit = 127 - 16
  y_upper_limit = 127 - 16 - 20
end

function define_characters()
  characters = {
    c1 = {
      projectile = {
        sprites = { 48, 49, 50, 51, 50, 49 },
        frames_per_sprite = 2
      },
      sprite_offset = 0,
      special_attacks = {
        fireball = create_special_attack("➡️➡️🅾️", { 18, 19 }, fire_projectile)
      }
    }
  }
end

function define_global_actions()
  actions = {
    block = create_action(2, nil, true, false, { 10, 11 }, action_types.other),
    crouch = create_action(2, nil, true, false, { 4, 5 }, action_types.other),
    flinch = create_action(6, flinch, false, false, { 34 }, action_types.damage_reaction),
    flying_kick = create_action(3, attack, false, true, { 14 }, action_types.aerial_attack),
    flying_punch = create_action(3, attack, false, true, { 15 }, action_types.aerial_attack),
    hook = create_action(3, attack, false, true, { 6, 7, 8, 8, 8, 8, 8, 7 }, action_types.attack),
    idle = create_action(1, nil, false, false, { 0 }, action_types.other),
    jump = create_action(2, nil, false, false, { 16, 17, { 16, true, true }, { 17, true, true } }, action_types.aerial),
    kick = create_action(4, attack, false, true, { 12, 13, 12 }, action_types.attack),
    prone = create_action(2, nil, false, false, { 33, 33, 5, 4 }, action_types.damage_reaction),
    propelled = create_action(3, nil, true, false, { 34, 35 }, action_types.damage_reaction),
    punch = create_action(3, attack, false, true, { 7, 9, 7 }, action_types.attack),
    walk = create_action(4, walk, false, false, { 1, 2, 3, 2 }, action_types.movement)
  }
end

function create_action(frames_per_sprite, handler, is_holdable, is_pixel_shiftable, sprites, type)
  return {
    frames_per_sprite = frames_per_sprite,
    handler = handler,
    is_pixel_shiftable = is_pixel_shiftable,
    is_holdable = is_holdable,
    sprites = sprites,
    type = type
  }
end

function create_special_attack(sequence, sprites, handler)
  return {
    action = create_action(4, handler, false, false, sprites, action_types.special_attack),
    sequence = sequence
  }
end

function define_players()
  p1 = create_player(characters.c1, false)
  p2 = create_player(characters.c1, true, true)
end

function create_player(character, is_npc, is_challenger)
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
    is_npc = is_npc or false,
    is_pixel_shifted = false,
    is_orientation_locked = false,
    jump_acceleration = 0,
    particle_sets = {},
    x = is_challenger and 127 - 36 - sprite_w or 36,
    y = y_bottom_limit
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end