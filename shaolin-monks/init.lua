function _init()
  actions = {
    idle = {
      i = 1,
      s = { 0 },
      f = 1,
      l = false,
      r = false
    },
    punch = {
      i = 2,
      s = { 4, 5, 4 },
      f = 3,
      l = true,
      r = true
    },
    kick = {
      i = 3,
      s = { 6, 7, 6 },
      f = 3,
      l = true,
      r = true
    },
    backward = {
      i = 4,
      s = { 1, 2, 3, 2, 1 },
      f = 4,
      l = false,
      r = true
    },
    forward = {
      i = 5,
      s = { 1, 2, 3, 2, 1 },
      f = 4,
      l = false,
      r = true
    },
    crouch = {
      i = 6,
      s = { 9, 10 },
      f = 4,
      l = false,
      r = true
    },
    stand = {
      i = 7,
      s = { 9 },
      f = 4,
      l = false,
      r = false
    }
  }
  directions = {
    left = -1,
    right = 1
  }
  player = {
    x = 8,
    y = 63,
    is_action_locked = false,
    current_action = actions.idle,
    current_sprite = 0,
    frames_counter = 0,
    direction = directions.right,
    is_pixel_shifted = false
  }
  pixel_shift = 2
  actions_stack = {}
  debug = {}
  action_handlers = {
    [actions.backward] = handle_backward,
    [actions.forward] = handle_forward,
    [actions.crouch] = handle_crouch,
    [actions.punch] = handle_punch,
    [actions.kick] = handle_kick
  }
  input_handlers = {
    [⬅️] = handle_⬅️,
    [➡️] = handle_➡️,
    [⬇️] = handle_⬇️,
    [🅾️] = handle_🅾️,
    [❎] = handle_❎
  }
end