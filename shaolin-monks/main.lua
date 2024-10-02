function _init()
  actions = {
    idle = 0,
    forward = 1,
    backward = 2,
    jump = 3,
    crouch = 4,
    punch = 5,
    kick = 6
  }
  player = {
    x = 63,
    y = 63,
    is_action_locked = false,
    current_action = actions.idle,
    current_sprite = 0,
    frames_counter = 0,
    animation_started = false
  }
  actions_stack = {}
end

function _update()
  if player.is_action_locked == false then
    if btnp(5) then
      set_action(actions.kick, true)
    end

    if btnp(4) then
      set_action(actions.punch, true)
    end

    if btnp(3) then
      set_action(actions.crouch)
    end
  end
end

function _draw()
  cls(3)

  for i = 1, #actions_stack do
    print(actions_stack[i], i * 10, 0)
  end

  if player.current_action == actions.punch then
    set_player_animation({ 3, 4, 3 }, 15, true)
  elseif player.current_action == actions.kick then
    set_player_animation({ 5, 6, 5 }, 15, true)
  elseif player.current_action == actions.crouch then
    set_player_animation({ 8, 9 }, 6)
  elseif player.current_action == actions.idle then
    player.current_sprite = 0
  end

  draw_player()
end

function draw_player()
  pal(5, 0)
  pal(13, 5)
  spr(player.current_sprite, player.x, player.y)
  pal()
end

function set_action(action, lock)
  if action != actions.idle then
    record_action(action)
  end

  player.current_action = action
  player.frames_counter = 0
  player.animation_started = false
  player.is_action_locked = lock or false
  poke(0x5f5c, lock == true and 255 or 0)
end

function set_player_animation(sprites, total_frames, tilt_forward)
  if player.animation_started == false then
    player.animation_started = true
    player.x += tilt_forward == true and 1 or 0
  else
    local fps = total_frames / #sprites

    player.current_sprite = sprites[flr(player.frames_counter / fps) + 1]

    player.frames_counter += 1

    if player.frames_counter >= total_frames - 1 then
      set_action(actions.idle)
      player.x -= tilt_forward == true and 1 or 0
    end
  end
end

function record_action(action)
  add(actions_stack, action)

  if #actions_stack > 10 then
    deli(actions_stack, 1)
  end
end