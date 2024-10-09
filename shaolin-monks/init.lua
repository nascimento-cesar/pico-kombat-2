function _init()
  define_global_variables()
  define_actions()
  define_players()
  disable_hold_function()
end

function define_global_variables()
  action_states = {
    finished = 1,
    held = 2,
    in_progress = 3,
    released = 4,
    special_move = 5
  }
  action_types = {
    aerial = 1,
    aerial_attack = 2,
    attack = 3,
    movement = 4,
    other = 5,
    special_attack = 6
  }
  characters = {
    c1 = {
      sprite_offset = 0,
      special_moves = {
        projectile = "➡️➡️🅾️"
      }
    }
  }
  debug = {}
  directions = {
    backward = -1,
    forward = 1
  }
  jump_speed = 2
  p = {}
  pixel_shift = 2
  y_bottom_limit = 127 - 16
  y_upper_limit = 127 - 16 - 20
end

function define_actions()
  actions = {
    block = create_action(2, nil, true, false, { 10, 11 }, action_types.other),
    crouch = create_action(2, nil, true, false, { 4, 5 }, action_types.other),
    flying_kick = create_action(3, nil, false, true, { 14 }, action_types.aerial_attack),
    flying_punch = create_action(3, nil, false, true, { 15 }, action_types.aerial_attack),
    hook = create_action(3, nil, false, true, { 6, 7, 8, 8, 8, 8, 8, 7 }, action_types.attack),
    idle = create_action(1, nil, false, false, { 0 }, action_types.other),
    jump = create_action(2, nil, false, false, { 16, 17, { 16, true, true }, { 17, true, true } }, action_types.aerial),
    kick = create_action(4, nil, false, true, { 12, 13, 12 }, action_types.attack),
    punch = create_action(3, nil, false, true, { 7, 9, 7 }, action_types.attack),
    projectile = create_action(4, nil, false, true, { 18, 19 }, action_types.special_attack),
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

function define_players()
  p1 = create_player(characters.c1)
  players = { p1 }
end

function create_player(character, is_npc)
  return {
    action_stack = "",
    character = character,
    current_action = actions.idle,
    current_action_params = {},
    current_action_state = action_states.in_progress,
    facing = directions.forward,
    frames_counter = 0,
    is_npc = is_npc or false,
    is_pixel_shifted = false,
    jump_acceleration = 0,
    x = 8,
    y = y_bottom_limit
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end