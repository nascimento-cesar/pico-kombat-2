function _init()
  debug = {}
  general = configure_general()
  actions = configure_actions()
  p1 = configure_player(general.characters.c2)
  players = { p1 }
  action_handlers = configure_action_handlers()
  disable_hold_function()
end

function configure_general()
  return {
    characters = {
      c1 = 0,
      c2 = 32
    },
    directions = {
      left = -1,
      right = 1
    },
    pixel_shift = 2,
    axes = {
      x = { left_limit = 0, right_limit = 127 },
      y = { bottom_limit = 63, top_limit = 63 - 16 }
    }
  }
end

function configure_player(character, is_npc)
  return {
    action_stack = {},
    character = character,
    current_action = {
      action = actions.idle,
      is_finished = true,
      is_held = false
    },
    is_npc = is_npc or false,
    rendering = {
      x = 8,
      y = 63,
      current_sprite = 0,
      frames_counter = 0,
      facing = general.directions.right,
      is_pixel_shifted = false
    }
  }
end

function configure_actions()
  return {
    idle = set_action({ 0 }, 1, false, false),
    backward = set_action({ 1, 2, 3, 2 }, 4, true, false),
    forward = set_action({ 1, 2, 3, 2 }, 4, true, false),
    jump = set_action({ 23, 24, 23 }, 4, false, false),
    jump_backward = set_action({ 23, 24, 23 }, 4, false, false),
    jump_forward = set_action({ 23, 24, 23 }, 4, false, false),
    crouch = set_action({ 9, 10 }, 2, false, false),
    stand = set_action({ 9 }, 2, false, false),
    punch = set_action({ 4, 5, 4 }, 3, false, true),
    kick = set_action({ 6, 7, 6 }, 3, false, true),
    hook = set_action({ 16, 17, 18, 18, 18, 18, 18, 17 }, 2, false, true),
    block = set_action({ 19, 20 }, 2, false, false),
    unblock = set_action({ 19 }, 2, false, false)
  }
end

function configure_action_handlers()
  return {
    [actions.backward] = backward,
    [actions.forward] = forward,
    [actions.jump] = jump,
    [actions.jump_backward] = jump_backward,
    [actions.jump_forward] = jump_forward,
    [actions.crouch] = crouch,
    [actions.punch] = punch,
    [actions.kick] = kick,
    [actions.hook] = hook,
    [actions.block] = block
  }
end

function set_action(sprites, frames_per_sprite, is_movement, is_pixel_shiftable)
  return {
    sprites = sprites,
    frames_per_sprite = frames_per_sprite,
    is_movement = is_movement,
    is_pixel_shiftable = is_pixel_shiftable
  }
end

function disable_hold_function()
  poke(0x5f5c, 255)
end