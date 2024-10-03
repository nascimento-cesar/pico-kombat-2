function _init()
  actions = {
    idle = {
      i = 1,
      s = { 0 },
      f = 1,
      l = false
    },
    punch = {
      i = 2,
      s = { 3, 4, 3 },
      f = 3,
      l = true
    },
    kick = {
      i = 3,
      s = { 5, 6, 5 },
      f = 3,
      l = true
    }
  }
  player = {
    x = 63,
    y = 63,
    is_action_locked = false,
    current_action = actions.idle,
    current_sprite = 0,
    frames_counter = 0
  }
  actions_stack = {}
end