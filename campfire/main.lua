function _init()
  sp = 2
  speed = .3
end

function _draw()
  cls()
  animate()
end

function animate()
  if sp < 6 - speed then
    sp += speed
  else
    sp = 1
  end

  spr(sp, 63, 63)
end