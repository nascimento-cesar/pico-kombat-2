function _init()
  actions = {
    idle = 0,
    jump = 1,
    punch = 2,
    kick = 3,
    special_1 = 4,
    special_2 = 5,
    flying_attack = 6,
    block = 7,
    crouch = 8,
    hook = 9
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

  poke(0x5f5c, 255)
end

function _update()
  if player.is_action_locked == false then
    if btnp(❎) then
      set_action(actions.kick)
    end

    if btnp(🅾️) then
      set_action(actions.punch)
    end
  end
end

function _draw()
  cls(3)

  if player.current_action == actions.punch then
    set_player_animation({ 3, 4, 3 }, 6)
  end

  draw_player()
end

function draw_player()
  pal(5, 0)
  spr(player.current_sprite, player.x, player.y)
  pal()
end

function set_action(action)
  player.current_action = action
  player.frames_counter = 0
  player.animation_started = false
  player.is_action_locked = true
end

function set_idle()
  player.current_action = actions.idle
  player.frames_counter = 0
  player.animation_started = false
  player.is_action_locked = false
  player.current_sprite = 0
end

function set_player_animation(sprites, total_frames)
  if player.animation_started == false then
    player.animation_started = true
  else
    local fps = total_frames / #sprites

    player.current_sprite = sprites[flr(player.frames_counter / fps) + 1]

    player.frames_counter += 1

    if player.frames_counter >= total_frames - 1 then
      set_idle()
    end
  end
end