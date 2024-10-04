function _init()
  debug = {}
  general = configure_general()
  actions = configure_actions()
  player = configure_player()
  action_handlers = configure_action_handlers()
  input_handlers = configure_input_handlers()
end

function configure_general()
  return {
    directions = {
      left = -1,
      right = 1
    },
    pixel_shift = 2,
    actions_stack = {}
  }
end

function configure_player()
  return {
    x = 8,
    y = 63,
    is_action_locked = false,
    is_action_held = false,
    current_action = actions.idle,
    current_sprite = 0,
    frames_counter = 0,
    direction = general.directions.right,
    is_pixel_shifted = false
  }
end

function configure_actions()
  return {
    idle = set_action(1, { 0 }, 1, false, false, false),
    punch = set_action(2, { 4, 5, 4 }, 3, true, true, false),
    kick = set_action(3, { 6, 7, 6 }, 3, true, true, false),
    backward = set_action(4, { 1, 2, 3, 2, 1 }, 4, false, true, false),
    forward = set_action(5, { 1, 2, 3, 2, 1 }, 4, false, true, false),
    crouch = set_action(6, { 9, 10 }, 2, false, true, true),
    stand = set_action(7, { 9 }, 2, false, false, false)
  }
end

function configure_action_handlers()
  return {
    [actions.backward] = handle_backward,
    [actions.forward] = handle_forward,
    [actions.crouch] = handle_crouch,
    [actions.punch] = handle_punch,
    [actions.kick] = handle_kick
  }
end
function configure_input_handlers()
  return {
    [⬅️] = handle_⬅️,
    [➡️] = handle_➡️,
    [⬇️] = handle_⬇️,
    [🅾️] = handle_🅾️,
    [❎] = handle_❎
  }
end

function set_action(index, sprites, frames_per_sprite, locks_actions, recordable, holdable)
  return {
    i = index,
    s = sprites,
    f = frames_per_sprite,
    l = locks_actions,
    r = recordable,
    h = holdable
  }
end