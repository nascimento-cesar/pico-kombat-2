function _init()
  setup_game()
  state = "start"
end

function setup_game()
  player_sprite = 1
  px = 63
  py = 63
  flip_player = false
  points = 0
  goal = 2
end

function _update()
  if state == "play" then
    move_player()
  elseif state == "start" then
    if btnp(❎) then
      state = "play"
    end
  elseif state == "win" then
    if btnp(❎) then
      setup_game()
      state = "play"
    end
  end
end

function _draw()
  cls()

  if state == "play" then
    map()
    animate_player()
    pickup_items()
    compute_points()
  elseif state == "start" then
    print("press ❎ to start", 30, 60)
  elseif state == "win" then
    print("you win!", 30, 60)
  end
end

function move_player()
  local current_px = px
  local current_py = py

  if btn(⬅️) then
    flip_player = false
    px -= 1
  elseif btn(➡️) then
    flip_player = true
    px += 1
  end

  if btn(⬆️) then
    py -= 1
  elseif btn(⬇️) then
    py += 1
  end

  local tile_x = (px + 4) / 8
  local tile_y = (py + 4) / 8

  if fget(mget(tile_x, tile_y), 0) == true then
    px = current_px
    py = current_py
  end
end

function animate_player()
  if player_sprite > 3 then
    player_sprite = 1
  else
    player_sprite += .05
  end

  spr(player_sprite, px, py, 1, 1, flip_player)
end

function pickup_items()
  local tile_x = (px + 4) / 8
  local tile_y = (py + 4) / 8

  spover = mget(tile_x, tile_y)

  if spover == 7 then
    mset(tile_x, tile_y, 6)
    points += 1
  end

  if points >= goal then
    state = "win"
  end
end

function compute_points()
  print(points)
end